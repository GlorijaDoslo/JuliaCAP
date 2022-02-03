module JuliaCAP

export Grana, Graf, noviGraf, dodajGranu

using Symbolics
using SymbolicUtils
#using Parameters
using Printf
#using SymPy
#using DynamicPolynomials

@enum TipGrane R Vg Ig opAmp VCVS VCCS CCCS CCVS L C IdealT InductiveT ABCD Z Y T

#T is transmission line
j = Symbolics.Sym{Num}(Symbol("j"))

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
	else
		time_domain = true
		if omega isa String
			s = Symbolics.Sym{Num}(Symbol("j" * string(omega)))
		else
			s = j * omega
		end
	end
	simboli = Set{Symbolics.Sym{Num}}()	#namerno je Set da ne bi ubacio duplikate
	# smene = Dict{Symbolics.Sym{Num},
	# 			 SymbolicUtils.Div{Num, Int64, SymbolicUtils.Sym{Num, Nothing}, Nothing}}
	smene = Dict()
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
			#U = 0
			# if (time_domain == false)
			# 	push!(g.struja_napon, 0)
			# end
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
			# if JuliaCAP.time_domain == false
			# 	push!(g.struja_napon, 0)
			# 	push!(g.struja_napon, 0)
			# end
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

	jednacine = Vector{Equation}();

	# t = Symbolics.Sym{Num}(Symbol("U1")) ~ 0
	# push!(jednacine, t)

	append!(jednacine, grf.jednacine_grane)
	append!(jednacine, grf.jednacine_cvorovi[2:(end)])

	simboli_vec = Vector{Symbolics.Sym{Num}}()

	
	# for i in jednacine
	# 	println(i)
	# end

	# for i in jednacine[1:(end - 1)]
	# 	println(i)
	# end

	for i in simboli
		push!(simboli_vec, i)
	end
	#samo ispis
	U1 = Symbolics.Sym{Symbolics.Num}(Symbol("U1"))
	for (i, val) in enumerate(jednacine)
		jednacine[i] = Symbolics.Equation(Symbolics.substitute(val.lhs, Dict([U1 => 0])),
										  Symbolics.substitute(val.rhs, Dict([U1 => 0])))
		#jednacine[i] = Symbolics.simplify(jednacine[i], expand=true)
	end

	for i in jednacine[1:(end)]
		println(Symbolics.substitute(i, smene))
		#println(i)
	end

	print("Simboli: ")
	for i in simboli
	 	print(i, " ")
	end
	 println()


	
	# TODO: Да ли треба if - else
	# if omega == ""
	# 	res = Symbolics.solve_for(jednacine, simboli_vec, simplify = true)
	# 	for (i, val) in enumerate(res)
	# 		res[i] = Symbolics.simplify(Symbolics.substitute(val, smene), expand=true)
	# 	end
	# else
		#try
			res2 = Vector{Any}()
			res = Symbolics.solve_for(jednacine, simboli_vec)
			for i in res
				push!(res2, i)
			end

			#println(res)
		#catch
			#println(smene)
			#println("To complicated")
		 for (i, val) in enumerate(res2)
			#SymPy.simplify(res[i]);
			
			#res2[i] = Symbolics.substitute(val, smene)
		 	#res[i] = Symbolics.simplify(val)
			res2[i] = Symbolics.substitute(val, smene)
		
		 end
		#println("Stigao do ovde")
	#end
	# for j in res
	# 	j = round(j, digits=3)
	# end
	# println("Ponovo ispisi jednacine")
	# for i in jednacine[1:(end)]
	# 	println(i)
	# end

	ret = Vector{Tuple{Symbolics.Sym{Num}, Num}}()
	for i in zip(simboli_vec, res2)
		push!(ret, i)
	end

	return ret


end

function ispisi_rezultate(rez)
	for i in rez
		#Symbolics.simplify_fractions(i)
		@printf("%s = %s\n", i[1], i[2])
		#display(i)
	end
end

function ispisi_specifican_rezultat(rez, par)
	for i in rez
		if par == string(i[1])
			@printf("%s = %s\n", i[1], i[2])
		end
	end
end

end


graf = JuliaCAP.noviGraf()

#Test1 (radi)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [4], [1], [5.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [3], [150.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [2], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], [300.]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [4], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [3], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [2], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], ["R3"]))

# @Symbolics.variables Ug Rp
# Ug = Symbolics.Sym{Symbolics.Num}(Symbol("Ug"))
# Rp = Symbolics.Sym{Symbolics.Num}(Symbol("Rp"))

# svi ovi testovi rade
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [3], [1], ["Ug"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [1], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [2], ["R2"]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["Ug"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [1], ["R"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [2], [1], ["R"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], ["R"]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [1], [100]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [2], [1], [100]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], [100]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [2]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], [50]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["Ug"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], ["R"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], ["R"]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [3], ["Ug"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [1], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], ["R2"]))


#Test2 (radi)


# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [5.])) #5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [514.]))#514
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [123.]))#123
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [4], [5], [300.]))#300
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [5], [1], [154.]))#154


# radi
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"])) #5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], ["R1"]))#514
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], ["R2"]))#123
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [4], [5], ["R3"]))#300
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [5], [1], ["R4"]))#154

#Test3 (ne radi kad dodas simplify, ni kad se dodaju dva simplify-a)
# ali radi bez simplify-a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [2], ["R1"]))#150
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], ["R3"]))#50
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [2], [3], ["R4"]))#200
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [4], [3], ["R5"]))#50
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [3], [1], ["R6"]))#100
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS, "VCCS1", [2, 1], [4, 1], ["g"]))#1

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], [5.]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [2], [150.]))#150
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], [50.]))#50
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [2], [3], [200.]))#200
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [4], [3], [50.]))#50
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [3], [1], [100.]))#100
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS, "VCCS1", [2, 1], [4, 1], [1.]))#1

#Test4 (radi)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [6], [1], [2.5]))#2.5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V2", [2], [1], [2]))#2
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [1], [4], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [2], [3], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R7", [3], [6], [2780]))#2780
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R8", [4], [5], [2780]))#2780
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [6], [1], ["V1"]))#2.5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V2", [2], [1], ["V2"]))#2
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [1], [4], ["R5"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [2], [3], ["R6"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R7", [3], [6], ["R7"]))#2780
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R8", [4], [5], ["R8"]))#2780
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

#Test6
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [100.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [4], [1], [5.], [2.]))

#Isto test6 samo sto su parametri nekih elemenata zamenjeni opstim simbolima
# ne radi kad ima simplify koji je unutar solvera
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [4], [1], ["C"], ["U0"]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [1], [5.], [2.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [4], [1], [5.], [2.]))

# radi sa dva simplify-a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [2], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [1], [5.], [2.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C2", [4], [1], [5.], [2.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS1", [2, 1], [3, 1], [1]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS2", [3, 1], [3, 1], [1]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS3", [3, 1], [4, 1], [1]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS4", [4, 1], [1, 3], [1]))#a

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [1], ["C1"], ["U01"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C2", [4], [1], ["C2"], ["U02"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS1", [2, 1], [3, 1], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS2", [3, 1], [3, 1], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS3", [3, 1], [4, 1], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS4", [4, 1], [1, 3], ["a"]))#a

# ne radi sa dva simplify-a, ali radi bez simplify
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [1], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [2], [4], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [2, 5], [6]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [2, 3], [4]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C2", [5], [6], [5.], [2.]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [1], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [3], ["R3"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], ["R4"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [2], [4], ["R5"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [2, 5], [6]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [2, 3], [4]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C2", [5], [6], ["C2"], ["U02"]))

#Test7 (radi sa dva simplify-a)

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [100.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [4], [1], [5.], [2.]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [4], [1], ["L1"], ["I01"]))

#Test9 (ne radi sa dva simplify-a)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [5], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [5], [6], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [3], ["R3"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [4], ["C1"], ["Uo"]))#3
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 1], [6]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [1, 5], [4]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [6], [1], ["R4"]))

# Test 10 (radi sa dva simplify-a)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [1], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [4], [5], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [5], [1], ["R3"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [2], [3], ["R4"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [5]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [1], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [4], [5], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [5], [1], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [2], [3], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

# Test 11 (T - sema) -> radi sa dva simplify-a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [5]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [6], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [1], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [6], [5], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [4], [1], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [5], [1], [10000]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [6], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [1], ["R3"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [6], [5], ["R4"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [4], [1], ["R5"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [5], [1], ["R6"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

# Test 12 (radi bez substitute, ali sa njim ne radi), u Linuxu ne radi, ne radi na win 7
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Ig, "Ig1", [1], [2], ["Ig1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Ig, "Ig2", [4], [3], ["Ig2"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [6], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [4], [1], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [5], ["R3"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [6], [3], ["R4"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [2, 6], [3]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [4, 6], [5]))

# Isto test 12 radi bez substitute, ali sa njim ne radi
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Ig, "Ig1", [1], [2], [5.]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Ig, "Ig2", [4], [3], [5.]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [6], [10000.]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [4], [1], [10000.]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [5], [10000.]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [6], [3], [10000.]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [2, 6], [3]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [4, 6], [5]))

# Test 13 (radi bez oba simplify-a, ali sa jednim ili dva ne radi)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [4], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [2], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [2], [3], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.InductiveT, "T1", [2, 1], [3, 1], ["L1", "L2", "L12"], ["I01", "I02"]))

# Test 14 (radi sa jednim i nijednim simplify, a sa dva ne radi)
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [4], [1], ["V1"]))#5
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [2], ["Zc"]))#10000
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], ["Zc"]))#10000
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.T, "T1", [2, 1], [3, 1], ["Zc", "tau"]))#10000

# ovo nije test primer
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], [200.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [5], [4], [50.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [4], [1], [100.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCVS,  "VCVS", [2, 1], [4, 1], 1))#a
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.CCVS,  "CCVS", [3, 1], [5, 1], 2.))#r
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS", [3, 1], [5, 1], 1.))#g
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.CCCS,  "CCCS", [3, 1], [5, 1], [5.]))#a
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

JuliaCAP.dumpDot(graf, "test.dot")

arg = Dict{String, Any}("w" => "w", "replacement" => "10")
rezultat = JuliaCAP.resiKolo(graf, arg)
JuliaCAP.ispisi_rezultate(rezultat)
#println()
#JuliaCAP.ispisi_specifican_rezultat(rezultat, "U2")

# TODO
#NAPRAVITI LEP ISPIS JEDNACINA
#ZAOKRUZITI VREDNOSTI I OBRISATI -0
#PROVERITI GRESKE


#x=Symbolics.Sym{Num}(Symbol("x"))
#Symbolics.@syms x :: Symbolics.Sym{Num}
# x = Symbolics.Sym{Num}(Symbol("x"))
# R = Symbolics.Sym{Num}(Symbol("R"))
# function f!(F,x)
# 	F[1]=x[1]^2-25
# 	F[2]=x[2]^2 - 9
# end
# function g!(F,x)
# 	x[1]^2 - 25
# end

# res = nlsolve(g!, [1.0, 1.0])
# print(res.zero)
# using SymPy
# for i in vec
# 	print(SymPy.solveset(x^2 - 25, x))
# end
# x=symbols("x")
# y=symbols("y")
# print(SymPy.solveset((x^2 - 25 + y, y), [x, y]))
# a,b=symbols("a b")
# nonlinsolve(a^2 - 25, a)
# x = SymPy.symbols("x")
# y = SymPy.symbols("y")
# sim = [x, y]
#z = SymPy.symbols("z")
#SymPy.solve((SymPy.Eq(3*x+7*y, 0), SymPy.Eq(4*x-2*y, 0)), (x, y))
#x, y = @vars x y
#dist = [x^2 - 25]
#equations = [Eq(dist, 0)]
# eq = Vector{Equation}()
# push!(eq, x^2 - 25 ~ 0)
# equa = Vector{Sym}()
# push!(equa, "x^2 - 25 ~ 0")
# push!(equa, y - x ~ 0)
# sol = solve(equa, sim)
# using Symbolics
# x = Symbolics.Sym{Num}(Symbol("x"))
# y = Symbolics.Sym{Num}(Symbol("x"))
# a = Symbolics.Sym{Num}(Symbol("x"))
# Symbolics.solve_for([x + y ~ a, x - y ~ 0], [x, y])
