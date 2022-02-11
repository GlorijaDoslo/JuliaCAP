module JuliaCAP

export Grana, Graf, noviGraf, dodajGranu, resiKolo, ispisi_rezultate, ispisi_specifican_rezultat, ispisi_rezultate_latex
export ispisi_specifican_rezultat_latex, ispisi_specifikacije_kola, ispisi_jednacine, ispisi_jednacine_latex
export TipGrane, R, Vg, Ig, opAmp, VCVS, VCCS, CCCS, CCVS, L, C, IdealT, InductiveT, ABCD, Z, Y, T

using Symbolics
using SymbolicUtils
using Latexify
using Printf

@enum TipGrane R Vg Ig opAmp VCVS VCCS CCCS CCVS L C IdealT InductiveT ABCD Z Y T

#T is transmission line
j = Symbolics.Sym{Num}(Symbol("j"))
jednacine = Vector{Equation}();
simboli_vec = Vector{Symbolics.Sym{Num}}()
time_domain = false
smene = Dict()


struct Grana
	tip :: TipGrane
	ime :: String
	cvor1 :: Vector{Int}
	cvor2 :: Vector{Int}
	param :: Vector{}
	struja_napon :: Vector{}
	function Grana(t :: TipGrane, i :: String, c1 :: Vector{Int}, c2 :: Vector{Int}, p :: Vector{} = Vector{}()
		, st :: Vector{} = Vector{}())
		#push!(st, 0)
		#push!(p, 0)
		return new(t, i, c1, c2, p, st)
	end

end

problem = false

mutable struct Graf
	jednacine_cvorovi :: Vector{Equation}
	jednacine_grane   :: Vector{Equation}
	grane             :: Vector{Grana}
	max_cvor          :: Int

end

function noviGraf()
	return Graf(Vector{Num}(), Vector{Num}(), Vector{Grana}(), 0)
end

function dodajGranu(grf :: Graf, grn :: Grana)
	for j in grn.cvor1
		if j > grf.max_cvor
			grf.max_cvor = j
		end
	end
	for j in grn.cvor2
		if j > grf.max_cvor
			grf.max_cvor = j
		end
	end
	push!(grf.grane, grn)
end

function dumpDot(grf :: Graf, fajl :: String)
	open(fajl, "w") do file
		write(file, "graph g {\n")
		for g in grf.grane
			write(file, "	" * string(g.cvor1[1]) * " -- "
				  * string(g.cvor2[1]) * " [label = \"" * g.ime * "\"];\n")
		end
		write(file, "}")
	end
end

function resiKolo(grf :: Graf, args :: Dict)
	grf.jednacine_cvorovi = Vector{Equation}(undef, grf.max_cvor)
	t = Vector{Num}(undef, grf.max_cvor)
	for i in 1:length(t)
		t[i] = 0
	end
	grf.jednacine_grane = Vector{Equation}()

	######### Reading omega and replacement ##########
	omega = ""
	for a in keys(args)	#lista kljuceva
		if a == "w" || a == "omega"
			omega = args[a]
		end
		if a == "replacement" || a == "r"
			replacement_rule = args[a]
		end
	end

	if omega == ""
		time_domain = false
		s = Symbolics.Sym{Num}(Symbol("s"))
	else
		time_domain = true
		if omega isa String
			s = Symbolics.Sym{Num}(Symbol("j" * string(omega)))
		else
			s = j * omega
		end
	end
	simboli = Set{Symbolics.Sym{Num}}()	#namerno je Set da ne bi ubacio duplikate
	id = 1


	for g in grf.grane
		if g.tip == R
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U2)
			end

			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1
			I = (U1 - U2) * G
			#provera da li je simbol ili broj
			if g.param isa Vector{String}
				push!(smene, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
			else
				push!(smene, G => 1 / g.param[1])
				#I = (U1 - U2) / g.param[1]
			end

			t[g.cvor1[1]] += I
			t[g.cvor2[1]] -= I

		elseif g.tip == Vg
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U2)
			end
			Iug = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, Iug)
			t[g.cvor1[1]] += Iug
			t[g.cvor2[1]] -= Iug

			#provera da li je simbol ili broj
			if g.param isa Vector{String}
				Eq = U1 - U2 ~ Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				Eq = U1 - U2 ~ g.param[1]
			end

			push!(grf.jednacine_grane, Eq)

		elseif g.tip == Ig
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U2)
			end


			if g.param isa Vector{String}
				t[g.cvor1[1]] += Symbolics.Sym{Num}(Symbol(g.param[1]))
				t[g.cvor2[1]] -= Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				t[g.cvor1[1]] += g.param[1]
				t[g.cvor2[1]] -= g.param[1]
			end

		elseif g.tip == opAmp

			IopAmp = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, IopAmp)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end

			t[g.cvor2[1]] += IopAmp
			Eq = U1 - U2 ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == VCVS
			#g.param is amplification(voltage gain)
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			t[g.cvor2[1]] += I1
			t[g.cvor2[2]] -= I1
			if g.param isa Vector{String}
				Eq = U3 - U4 - Symbolics.Sym{Num}(Symbol(g.param[1])) * (U1 - U2) ~ 0
			else
				Eq = U3 - U4 - g.param[1] * (U1 - U2) ~ 0
			end
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == VCCS
			#g.param is transconductance
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			if g.param isa Vector{String}
				t[g.cvor2[1]] += Symbolics.Sym{Num}(Symbol(g.param[1])) * (U1 - U2)
				t[g.cvor2[2]] -= Symbolics.Sym{Num}(Symbol(g.param[1])) * (U1 - U2)
			else
				t[g.cvor2[1]] += g.param[1] * (U1 - U2)
				t[g.cvor2[2]] -= g.param[1] * (U1 - U2)
			end

		elseif g.tip == CCCS
			#g.param is amplification(current gain)
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			if g.param isa Vector{String}
				t[g.cvor2[1]] += Symbolics.Sym{Num}(Symbol(g.param[1])) * I1
				t[g.cvor2[2]] -= Symbolics.Sym{Num}(Symbol(g.param[1])) * I1
			else
				t[g.cvor2[1]] += g.param[1] * I1
				t[g.cvor2[2]] -= g.param[1] * I1
			end

			Eq = U1 - U2 ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == CCVS
			#g.param is transresistance
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1
			I = (U3 - U4) * G

			if g.param isa Vector{String}
				push!(smene, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
			else
				push!(smene, G => 1 / g.param[1])
			end

			#t[g.cvor1[1]] += (U3 - U4) / g.param[1]
			#t[g.cvor1[2]] -= (U3 - U4) / g.param[1]
			t[g.cvor1[1]] += I
			t[g.cvor1[2]] -= I

			t[g.cvor2[1]] += I1
			t[g.cvor2[2]] -= I1

			Eq = U1 - U2 ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == L
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U2)
			end
			#I = 0
			if isempty(g.struja_napon)
				push!(g.struja_napon, 0)
			end

			S1 = Symbolics.Sym{Num}(Symbol("S" * string(id)))
			id += 1
			S2 = Symbolics.Sym{Num}(Symbol("S" * string(id)))
			id += 1

			if g.struja_napon isa Vector{String}
				I1 = (U1 - U2) * S1 + Symbolics.Sym{Num}(Symbol(g.struja_napon[1])) * S2
				I2 = (U2 - U1) * S1 - Symbolics.Sym{Num}(Symbol(g.struja_napon[1])) * S2

				if g.param isa Vector{String}
					push!(smene, S1 => 1 / (Symbolics.Sym{Num}(Symbol(g.param[1])) * s))
					push!(smene, S2 => 1 / s)
				else
					push!(smene, S2 => 1 / s)
					I1 = (U1 - U2) * S2 / g.param[1] + Symbolics.Sym{Num}(Symbol(g.struja_napon[1])) * S2
					I2 = (U2 - U1) * S2 / g.param[1] - Symbolics.Sym{Num}(Symbol(g.struja_napon[1])) * S2
				end

			else
				I1 = (U1 - U2) * S1 + g.struja_napon[1] * S2
				I2 = (U2 - U1) * S1 - g.struja_napon[1] * S2

				if g.param isa Vector{String}
					push!(smene, S1 => 1 / (Symbolics.Sym{Num}(Symbol(g.param[1])) * s))
					push!(smene, S2 => 1 / s)
				else
					push!(smene, S2 => 1 / s)
					I1 = (U1 - U2) * S2 / g.param[1] + g.struja_napon[1] * S2
					I2 = (U2 - U1) * S2 / g.param[1] - g.struja_napon[1] * S2
				end
			end

			#t[g.cvor1[1]] += (U1 - U2) / (s * g.param[1]) + g.struja_napon[1] / s
			#t[g.cvor2[1]] += (U2 - U1) / (s * g.param[1]) - g.struja_napon[1] / s
			t[g.cvor1[1]] += I1
			t[g.cvor2[1]] += I2

		elseif g.tip == C
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U2)
			end

			if isempty(g.struja_napon)
				push!(g.struja_napon, 0)
			end

			if (g.struja_napon isa Vector{String} && g.param isa Vector{String})
				par = Symbolics.Sym{Num}(Symbol(g.param[1]))
				str_nap = Symbolics.Sym{Num}(Symbol(g.struja_napon[1]))
				t[g.cvor1[1]] += (U1 - U2) * s * par - str_nap * par
				t[g.cvor2[1]] += (U2 - U1) * s * par + str_nap * par
			elseif g.struja_napon isa Vector{String}
				str_nap = Symbolics.Sym{Num}(Symbol(g.struja_napon[1]))
				t[g.cvor1[1]] += (U1 - U2) * s * g.param[1] - str_nap * g.param[1]
				t[g.cvor2[1]] += (U2 - U1) * s * g.param[1] + str_nap * g.param[1]
			elseif g.param isa Vector{String}
				par = Symbolics.Sym{Num}(Symbol(g.param[1]))
				t[g.cvor1[1]] += (U1 - U2) * s * par - g.struja_napon[1] * par
				t[g.cvor2[1]] += (U2 - U1) * s * par + g.struja_napon[1] * par
			else
				t[g.cvor1[1]] += (U1 - U2) * s * g.param[1] - g.struja_napon[1] * g.param[1]
				t[g.cvor2[1]] += (U2 - U1) * s * g.param[1] + g.struja_napon[1] * g.param[1]
			end

		elseif g.tip == IdealT

			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			if g.param isa Vector{String}
				t[g.cvor2[1]] += -Symbolics.Sym{Num}(Symbol(g.param[1])) * I1
				t[g.cvor2[2]] -= Symbolics.Sym{Num}(Symbol(g.param[1])) * I1

				Eq = (U1 - U2) - Symbolics.Sym{Num}(Symbol(g.param[1])) * (U3 - U4) ~ 0
			else
				t[g.cvor2[1]] += -g.param[1] * I1
				t[g.cvor2[2]] -= g.param[1] * I1

				Eq = (U1 - U2) - g.param[1] * (U3 - U4) ~ 0
			end
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == InductiveT
			# L1, L2, L12, I01, I02
			
			if isempty(g.struja_napon)
				push!(g.struja_napon, 0)
				if length(g.struja_napon) == 1
					push!(g.struja_napon, 0)
				end
			end

			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			t[g.cvor2[1]] += I2
			t[g.cvor2[2]] -= I2

			if (g.param isa Vector{String} && !(g.struja_napon isa Vector{String}))
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				par3 = Symbolics.Sym{Num}(Symbol(g.param[3]))
				Eq = U1 - U2 - (par1 * s * I1 - par1 * g.struja_napon[1] + par3 * s * I2 - par3 * g.struja_napon[2]) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = U3 - U4 - (par3 * s * I1 - par3 * g.struja_napon[1] + par2 * s * I2 - par2 * g.struja_napon[2]) ~ 0
				push!(grf.jednacine_grane, Eq)

			elseif (g.struja_napon isa Vector{String} && !(g.param isa Vector{String}))
				str1 = Symbolics.Sym{Num}(Symbol(g.struja_napon[1]))
				str2 = Symbolics.Sym{Num}(Symbol(g.struja_napon[2]))
				Eq = U1 - U2 - (g.param[1] * s * I1 - g.param[1] * str1 + g.param[3] * s * I2 - g.param[3] * str2) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = U3 - U4 - (g.param[3] * s * I1 - g.param[3] * str1 + g.param[2] * s * I2 - g.param[2] * str2) ~ 0
				push!(grf.jednacine_grane, Eq)

			elseif (g.param isa Vector{String} && g.struja_napon isa Vector{String})
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				par3 = Symbolics.Sym{Num}(Symbol(g.param[3]))
				str1 = Symbolics.Sym{Num}(Symbol(g.struja_napon[1]))
				str2 = Symbolics.Sym{Num}(Symbol(g.struja_napon[2]))

				Eq = U1 - U2 - (par1 * s * I1 - par1 * str1 + par3 * s * I2 - par3 * str2) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = U3 - U4 - (par3 * s * I1 - par3 * str1 + par2 * s * I2 - par2 * str2) ~ 0
				push!(grf.jednacine_grane, Eq)
			else
				Eq = U1 - U2 - (g.param[1] * s * I1 - g.param[1] * g.struja_napon[1] + g.param[3] * s * I2 - g.param[3] * g.struja_napon[2]) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = U3 - U4 - (g.param[3] * s * I1 - g.param[3] * g.struja_napon[1] + g.param[2] * s * I2 - g.param[2] * g.struja_napon[2]) ~ 0
				push!(grf.jednacine_grane, Eq)
			end

		elseif g.tip == ABCD
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			t[g.cvor2[1]] -= I2
			t[g.cvor2[2]] += I2

			if g.param isa Vector{String}
				Eq = U1 - U2 - (Symbolics.Sym{Num}(Symbol(g.param[1])) * U3 - U4 + Symbolics.Sym{Num}(Symbol(g.param[2])) * I2) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = I1 - (Symbolics.Sym{Num}(Symbol(g.param[3])) * U3 - U4 + Symbolics.Sym{Num}(Symbol(g.param[4])) * I2) ~ 0
				push!(grf.jednacine_grane, Eq)
			else
				Eq = U1 - U2 - (g.param[1] * U3 - U4 + g.param[2] * I2) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = I1 - (g.param[3] * U3 - U4 + g.param[4] * I2) ~ 0
				push!(grf.jednacine_grane, Eq)
			end

		elseif g.tip == Z
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end

			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1
			#provera da li je simbol ili broj
			if g.param isa Vector{String}
				push!(smene, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
			else
				push!(smene, G => 1 / g.param[1])
			end

			t[g.cvor1[1]] += (U1 - U2) * G
			t[g.cvor2[1]] -= (U1 - U2) * G

		elseif g.tip == Y
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end

			if g.param isa Vector{String}
				t[g.cvor1[1]] += (U1 - U2) * Symbolics.Sym{Num}(Symbol(g.param[1]))
				t[g.cvor2[1]] -= (U1 - U2) * Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				t[g.cvor1[1]] += (U1 - U2) * g.param[1]
				t[g.cvor2[1]] -= (U1 - U2) * g.param[1]
			end

		elseif (g.tip == T && time_domain == true)					#####################   NEDOVRSENO
			#Zc, theta -> g.param
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			t[g.cvor2[1]] -= I2
			t[g.cvor2[2]] += I2
			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1

			#globalna konstanta im = j
			if g.param isa Vector{String}
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				push!(smene, G => 1 / par1)
				Eq = U1 - U2 - (cos(par2) * (U3 - U4) + j * par1 * sin(par2) * I2) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = I1 - (j * G * sin(par2) * (U3 - U4) + cos(par2) * I2) ~ 0
				push!(grf.jednacine_grane, Eq)
			else
				push!(smene, G => 1 / g.param[1])
				Eq = U1 - U2 - (cos(g.param[2]) * (U3 - U4) + j * g.param[1] * sin(g.param[2]) * I2) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = I1 - (j * G * sin(g.param[2]) * (U3 - U4) + cos(g.param[2]) * I2) ~ 0
				push!(grf.jednacine_grane, Eq)
			end

		elseif (g.tip == T && time_domain == false)			#######TODO: NE VALJAJU JEDNACINE
			#Zc, tau -> g.param
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			if g.cvor1[2] != 1
				push!(simboli, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			if g.cvor2[2] != 1
				push!(simboli, U4)
			end

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			t[g.cvor2[1]] += I2
			t[g.cvor2[2]] -= I2
			if g.param isa Vector{String}
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				Eq = U1 - U2 - (par1 * I1 + par1 * I2 * exp(-par2 * s) + (U3 - U4) * exp(-par2 * s)) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = U3 - U4 - (par1 * I2 + par1 * I1 * exp(-par2 * s) + (U1 - U2) * exp(-par2 * s)) ~ 0
				push!(grf.jednacine_grane, Eq)
			else
				Eq = U1 - U2 - (g.param[1] * I1 + g.param[1] * I2 * exp(-g.param[2] * s) + (U3 - U4) * exp(-g.param[2] * s)) ~ 0
				push!(grf.jednacine_grane, Eq)

				Eq = U3 - U4 - (g.param[1] * I2 + g.param[1] * I1 * exp(-g.param[2] * s) + (U1 - U2) * exp(-g.param[2] * s)) ~ 0
				push!(grf.jednacine_grane, Eq)
			end
		end
	end

	for i in 1:length(grf.jednacine_cvorovi)
		grf.jednacine_cvorovi[i] = t[i] ~ 0
	end

	#jednacine = Vector{Equation}();

	# t = Symbolics.Sym{Num}(Symbol("U1")) ~ 0
	# push!(jednacine, t)

	append!(jednacine, grf.jednacine_grane)
	append!(jednacine, grf.jednacine_cvorovi[2:(end)])

	#simboli_vec = Vector{Symbolics.Sym{Num}}()


	# for i in jednacine
	# 	println(i)
	# end

	for i in simboli
		push!(simboli_vec, i)
	end


	U1 = Symbolics.Sym{Symbolics.Num}(Symbol("U1"))
	for (i, val) in enumerate(jednacine)
		jednacine[i] = Symbolics.Equation(Symbolics.substitute(val.lhs, Dict([U1 => 0])),
										  Symbolics.substitute(val.rhs, Dict([U1 => 0])))
		#jednacine[i] = Symbolics.simplify(jednacine[i], expand=true)
	end
	
	res2 = Vector{Any}()
	ret = Vector{Tuple{Symbolics.Sym{Num}, Num}}()

	a, b = Symbolics.linear_expansion(jednacine, simboli_vec)

	if isempty(a)
		println("Resenje ne postoji!")
		return ret
	end

	D = Symbolics.det(a)

	if isequal(D, 0)
		println("Resenje ne postoji!") 
		return ret
	end
	
	# for i in jednacine[1:(end)]
	# 	println(Symbolics.substitute(i, smene))
	# 	#println(i)
	# end

	# print("Simboli: ")
	# for i in simboli
	#  	print(i, " ")
	# end
	# println()

	res = Symbolics.solve_for(jednacine, simboli_vec)
	if isempty(res) 
		problem = true
	end

	for i in res
		push!(res2, i)
	end

	for (i, val) in enumerate(res2)
		#SymPy.simplify(res[i]);

		#res2[i] = Symbolics.substitute(val, smene)
		#res[i] = Symbolics.simplify(val)
		res2[i] = Symbolics.substitute(val, smene)

	end

	for i in zip(simboli_vec, res2)
		push!(ret, i)
	end

	return ret

end

function ispisi_jednacine()
	for i in jednacine
		println(Symbolics.substitute(i, smene))
	end
end

function ispisi_jednacine_latex()
	for i in jednacine
		println(latexify(Symbolics.substitute(i, smene)))
	end
end

function ispisi_rezultate(rez)
	for i in rez
		if problem
			println("Resenje ne postoji!")
		end
		@printf("%s = %s\n", i[1], i[2])
		#display(i)
	end
end

function ispisi_rezultate_latex(rez)
	for (k, v) in rez
		println(latexify(k ~ v))
	end
end

function ispisi_specifican_rezultat(rez, par)
	for i in rez
		if par == string(i[1])
			@printf("%s = %s\n", i[1], i[2])
		end
	end
end

function ispisi_specifican_rezultat_latex(rez, par)
	for (k,v) in rez
		if par == string(k)
			println(latexify(k ~ v))
		end
	end
end

function ispisi_specifikacije_kola(graf1)
	println("Specifikacije kola: ")
	println("Broj cvorova: ", graf1.max_cvor)
	print("Uneti elementi: ")
	for i in graf1.grane
		print(i.tip, " ")
	end
	println()
	#println("Replacement rule: ",self.replacement_rule)
	println("Jednacine: ")
	for i in jednacine
		println(i)
	end
	println("Varijable: ")
	for i in simboli_vec
		print(i, " ")
	end
	println()
	if time_domain
		print("Frekvencija: ")
		println(-s)
	end
end

end
