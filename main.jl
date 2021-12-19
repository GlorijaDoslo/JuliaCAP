module JuliaCAP

export Grana, Graf, noviGraf, dodajGranu

using Symbolics
using SymbolicUtils
using Parameters
using NLsolve

@enum TipGrane R Vg Ig opAmp VCVS VCCS CCCS CCVS L C IdealT InductiveT ABCD Z Y T

#T is transmission line
time_domain = Bool(false)
s = 0

struct Grana
	tip :: TipGrane
	ime :: String
	cvor1 :: Vector{Int}
	cvor2 :: Vector{Int}
	param :: Vector{Float64}
	struja_napon :: Vector{Float64}
	function Grana(t :: TipGrane, i :: String, c1 :: Vector{Int}, c2 :: Vector{Int}, p :: Vector{Float64} = Vector{Float64}()
		, st :: Vector{Float64} = Vector{Float64}())
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
			s = im * Symbolics{Num}(Symbol(omega))
		else
			s = im * omega
		end
	end
	simboli = Set{Symbolics.Sym{Num}}()	#namerno je Set da ne bi ubacio duplikate
	#jednacine_ispis = Vector{Equation}()

	for g in grf.grane
		if g.tip == R
			# I = (g.cvor1 - g.cvor2) / g.param
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U2)
			#R1 = Symbolics.Sym{Num}(Symbol(g.ime))
			I = (U1 - U2) / g.param[1]

			t[g.cvor1[1]] += I
			t[g.cvor2[1]] -= I

			# println(g)
			# println(I)
		elseif g.tip == Vg
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U2)
			Iug = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, Iug)
			t[g.cvor1[1]] += Iug
			t[g.cvor2[1]] -= Iug
			Eq = U1 - U2 ~ g.param[1]
			push!(grf.jednacine_grane, Eq)

			# println(g)
			# println(Eq)
		elseif g.tip == Ig
			t[g.cvor1[1]] += g.param[1]
			t[g.cvor2[1]] -= g.param[1]

		elseif g.tip == opAmp
			IopAmp = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, IopAmp)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			t[g.cvor2[1]] += IopAmp
			Eq = U1 - U2 ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == VCVS
			#g.param is amplification
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor2[1]] += I1
			t[g.cvor2[2]] -= I1

			Eq = U3 - U4 - g.param[1] * (U1 - U2) ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == VCCS
			#g.param is transconductance
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			t[g.cvor2[1]] += g.param[1] * (U1 - U2)
			t[g.cvor2[2]] -= g.param[1] * (U1 - U2)

		elseif g.tip == CCCS
			#g.param is amplification
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			t[g.cvor2[1]] += g.param[1] * I1
			t[g.cvor2[2]] -= g.param[1] * I1
			
			Eq = U1 - U2 ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == CCVS
			#g.param is transresistance
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor1[1]] += (U3 - U4) / g.param[1]
			t[g.cvor1[2]] -= (U3 - U4) / g.param[1]
			t[g.cvor2[1]] += I1
			t[g.cvor2[2]] -= I1

			Eq = U1 - U2 ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == L
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U2)
			#I = 0
			t[g.cvor1[1]] += (U1 - U2) / (s * g.param[1]) + g.struja_napon[1] / s
			t[g.cvor2[1]] += (U2 - U1) / (s * g.param[1]) - g.struja_napon[1] / s

		elseif g.tip == C
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U2)
			#U = 0
			if (JuliaCAP.time_domain == false)
				push!(g.struja_napon, 0)
			end
			t[g.cvor1[1]] += (U1 - U2) * JuliaCAP.s * g.param[1] - g.struja_napon[1] * g.param[1]
			t[g.cvor2[1]] += (U2 - U1) * JuliaCAP.s * g.param[1] + g.struja_napon[1] * g.param[1]

		elseif g.tip == IdealT
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime))
			push!(simboli, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1		
			t[g.cvor2[1]] += -g.param[1] * I1
			t[g.cvor2[2]] -= g.param[1] * I1

			Eq = (U1 - U2) - g.param[1] * (U3 - U4) ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == InductiveT
			# L1, L2, L12, I01, I02
			if JuliaCAP.time_domain == false
				push!(g.struja_napon, 0)
				push!(g.struja_napon, 0)
			end
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1		
			t[g.cvor2[1]] += I2
			t[g.cvor2[2]] -= I2

			Eq = U1 - U2 - (g.param[1] * JuliaCAP.s * I1 - g.param[1] * g.struja_napon[1] + g.param[3] * JuliaCAP.s * I2 - g.param[3] * g.struja_napon[2]) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = U3 - U4 - (g.param[3] * JuliaCAP.s * I1 - g.param[3] * g.struja_napon[1] + g.param[2] * JuliaCAP.s * I2 - g.param[2] * g.struja_napon[2]) ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == ABCD
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1		
			t[g.cvor2[1]] -= I2
			t[g.cvor2[2]] += I2

			Eq = U1 - U2 - (g.param[1] * U3 - U4 + g.param[2] * I2) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = I1 - (g.param[3] * U3 - U4 + g.param[4] * I2) ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif g.tip == Z
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)

			t[g.cvor1[1]] += (U1 - U2) / g.param[1]
			t[g.cvor2[1]] -= (U1 - U2) / g.param[1]

		elseif g.tip == Y
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)

			t[g.cvor1[1]] += (U1 - U2) * g.param[1]
			t[g.cvor2[1]] -= (U1 - U2) * g.param[1]

		elseif (g.tip == T && time_domain == true)
			#Zc, theta -> g.param
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1
			t[g.cvor2[1]] -= I2
			t[g.cvor2[2]] += I2
			#globalna konstanta im = j
			Eq = U1 - U2 - (cos(g.param[2]) * (U3 - U4) + im * g.param[1] * sin(g.param[2]) * I2) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = I1 - (im * (1/g.param[1]) * sin(g.param[2]) * (U3 - U4) + cos(g.param[2]) * I2) ~ 0
			push!(grf.jednacine_grane, Eq)

		elseif (g.tip == T && time_domain == false)
			#Zc, tau -> g.param
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor1[1])))
			push!(simboli, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.ime * string(g.cvor2[1])))
			push!(simboli, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			push!(simboli, U1)
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[2])))
			push!(simboli, U2)
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			push!(simboli, U3)
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[2])))
			push!(simboli, U4)

			t[g.cvor1[1]] += I1
			t[g.cvor1[2]] -= I1		
			t[g.cvor2[1]] += I2
			t[g.cvor2[2]] -= I2

			Eq = U1 - U2 - (g.param[1] * I1 + g.param[1] * I2 * exp(-g.param[2] * JuliaCAP.s) + (U3 - U4) * exp(-g.param[2] * JuliaCAP.s)) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = U3 - U4 - (g.param[1] * I2 + g.param[1] * I1 * exp(-g.param[2] * JuliaCAP.s) + (U1 - U2) * exp(-g.param[2] * JuliaCAP.s)) ~ 0
			push!(grf.jednacine_grane, Eq)
		end
	end

	for i in 1:length(grf.jednacine_cvorovi)
		grf.jednacine_cvorovi[i] = t[i] ~ 0
	end

	jednacine = Vector{Equation}();
	t = Symbolics.Sym{Num}(Symbol("U1")) ~ 0
	push!(jednacine, t)

	append!(jednacine, grf.jednacine_grane)
	append!(jednacine, grf.jednacine_cvorovi[1:end])

	simboli_vec = Vector{Symbolics.Sym{Num}}()

	for i in simboli
		push!(simboli_vec, i)
	end
	#samo ispis
	for i in jednacine[1:end]
	 	println(i)
	end
	
	for i in simboli
	 	print(i, " ")
	end
	 println()



	if omega == ""
		res = Symbolics.solve_for(jednacine[1:length(simboli_vec)], simboli_vec)
	else
		res = nlsolve(jednacine[1:length(simboli_vec)], simboli_vec)
	end
	# for j in res
	# 	j = round(j, digits=3)
	# end

	ret = Vector{Tuple{Symbolics.Sym{Num}, Num}}()
	for i in zip(simboli_vec, res)
		push!(ret, i)
	end

	return ret


end

end
graf = JuliaCAP.noviGraf()

JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50.]))
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [100.]))
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [4], [1], [5e-9], [2.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], [200.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [5], [4], [50.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [4], [1], [100.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCVS,  "VCVS", [2, 1], [4, 1], 1))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.CCVS,  "CCVS", [3, 1], [5, 1], 2.))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS", [3, 1], [5, 1], 1.))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.CCCS,  "CCCS", [3, 1], [5, 1], [5.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

JuliaCAP.dumpDot(graf, "test.dot")

arg = Dict{String, Any}("w" => "w", "replacement" => "10")

for i in JuliaCAP.resiKolo(graf, arg)
	println(i)
end
# TODO
#NAPRAVITI LEP ISPIS JEDNACINA
#ZAOKRUZITI VREDNOSTI I OBRISATI -0
#PROVERITI GRESKE

#kod symPyCAP uopste ne radi sa brojevima nego samo sa opstim vrednostima
#ovaj kod trenutno ne radi