module JuliaCAP

export Grana, Graf, noviGraf, dodajGranu

using Symbolics
using SymbolicUtils
using Parameters
using NLsolve
using Printf
# using SymPy


@enum TipGrane R Vg Ig opAmp VCVS VCCS CCCS CCVS L C IdealT InductiveT ABCD Z Y T

#T is transmission line
#time_domain = Bool(false)
j = Symbolics.Sym{Num}(Symbol("j"))
#omega = ""

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
	#jednacine_ispis = Vector{Equation}()
	# smene = Dict{Symbolics.Sym{Num},
	# 			 SymbolicUtils.Div{Num, Int64, SymbolicUtils.Sym{Num, Nothing}, Nothing}}
	smene = Dict()
	id = 0

	for g in grf.grane
		if g.tip == R
			# I = (g.cvor1 - g.cvor2) / g.param
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor1[1])))
			if g.cvor1[1] != 1
				push!(simboli, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.cvor2[1])))
			if g.cvor2[1] != 1
				push!(simboli, U2)
			end

			if g.param isa Vector{String}
				G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
				id += 1
				push!(smene, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
				I = (U1 - U2) * G
				t[g.cvor1[1]] += I
				t[g.cvor2[1]] -= I
			elseif g.param isa Symbolics.Sym{Num}
				G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
				id += 1
				push!(smene, G => 1 / g.param) # g.param je onda simbol, ako nije niz
				I = (U1 - U2) * G
				t[g.cvor1[1]] += I
				t[g.cvor2[1]] -= I
			end

			# println(g)
			# println(I)
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
			if g.param isa Vector{String}
				Eq = U1 - U2 ~ Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				Eq = U1 - U2 ~ g.param[1]
			end
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
			#g.param is amplification(voltage gain)
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
			#g.param is amplification(current gain)
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

			Eq = U1 - U2 - (g.param[1] * s * I1 - g.param[1] * g.struja_napon[1] + g.param[3] * s * I2 - g.param[3] * g.struja_napon[2]) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = U3 - U4 - (g.param[3] * s * I1 - g.param[3] * g.struja_napon[1] + g.param[2] * s * I2 - g.param[2] * g.struja_napon[2]) ~ 0
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
			Eq = U1 - U2 - (cos(g.param[2]) * (U3 - U4) + j * g.param[1] * sin(g.param[2]) * I2) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = I1 - (j * (1/g.param[1]) * sin(g.param[2]) * (U3 - U4) + cos(g.param[2]) * I2) ~ 0
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

			Eq = U1 - U2 - (g.param[1] * I1 + g.param[1] * I2 * exp(-g.param[2] * s) + (U3 - U4) * exp(-g.param[2] * s)) ~ 0
			push!(grf.jednacine_grane, Eq)

			Eq = U3 - U4 - (g.param[1] * I2 + g.param[1] * I1 * exp(-g.param[2] * s) + (U1 - U2) * exp(-g.param[2] * s)) ~ 0
			push!(grf.jednacine_grane, Eq)
		end
	end

	for i in 1:length(grf.jednacine_cvorovi)
		grf.jednacine_cvorovi[i] = t[i] ~ 0
	end

	jednacine = Vector{Equation}();

	# t = Symbolics.Sym{Num}(Symbol("U1")) ~ 0
	# push!(jednacine, t)

	append!(jednacine, grf.jednacine_grane)
	append!(jednacine, grf.jednacine_cvorovi[1:(end - 1)])

	simboli_vec = Vector{Symbolics.Sym{Num}}()

	for i in simboli
		push!(simboli_vec, i)
	end
	#samo ispis
	U1 = Symbolics.Sym{Symbolics.Num}(Symbol("U1"))
	for i in jednacine
		i = Symbolics.substitute(i.lhs, Dict([U1 => 0])) ~ Symbolics.substitute(i.rhs, Dict([U1 => 0]))
	 	println(i)
	end

	print("Simboli: ")
	for i in simboli
	 	print(i, " ")
	end
	 println()



	if omega == ""
		res = Symbolics.solve_for(jednacine, simboli_vec)
	else
		res = Symbolics.solve_for(jednacine, simboli_vec)
		#x = SymPy.symbols("x")
		#r = Array{Num}()
		# r = Vector{Sym}()
		# for i in simboli_vec
		# 	e = SymPy.symbols(string(i))
		# 	push!(r, e)
		# end
		# for i in jednacine[1:end]
		# 	push!(r, i)
		# end
		#res = solve(jednacine, r)
		#res = SymPy.solveset(jednacine[1:length(simboli_vec)], simboli_vec)
		#res = nlsolve(jednacine[1:length(simboli_vec)], simboli_vec)
		#x = Symbolics.Sym{Num}(Symbol("x"))
		# function f!(F,x)
		# 	F[1]=x[1]^2-25
		# 	F[2]=x[2]^2 - 9
		# end
		# nlsolve(f!, [5.0, 5.0])
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



#Test1
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [4], [1], [5.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [3], [150.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [2], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], [300.]))
@Symbolics.variables Ug Rp
Ug = Symbolics.Sym{Symbolics.Num}(Symbol("Ug"))
Rp = Symbolics.Sym{Symbolics.Num}(Symbol("Rp"))
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["Ug"]))
JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [1], ["Rp"]))

#Test2
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [5.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [514.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [123.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [4], [5], [300.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [5], [1], [154.]))

#Test3
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], [5.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [2], [150.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [1], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [2], [3], [200.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [4], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [3], [1], [100.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCVS, "VCVS1", [2, 1], [4, 1], [1]))

#Test4
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [6], [1], [2.5]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V2", [2], [1], [2.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [1], [4], [10000.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [2], [3], [10000.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R7", [3], [6], [2780.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R8", [4], [5], [2780.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

#Test6
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [100.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [4], [1], [5.], [2.]))

#Isto test6 samo sto su parametri nekih elemenata zamenjeni opstim simbolima
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [4], [1], ["C"], ["U0"]))

#Test7 (ERROR : isLinear)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [3], [50.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [4], [100.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [4], [1], [5.], [2.]))

#Test9 (ne radi)

# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], [5.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [5], [10000.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [5], [6], [10000.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [2], [3], [10000.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [4], [16e-9], [3.]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 1], [6]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [1, 5], [4]))

#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], [200.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [5], [4], [50.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R6", [4], [1], [100.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCVS,  "VCVS", [2, 1], [4, 1], 1))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.CCVS,  "CCVS", [3, 1], [5, 1], 2.))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS", [3, 1], [5, 1], 1.))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.CCCS,  "CCCS", [3, 1], [5, 1], [5.]))
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [3, 4], [5]))

JuliaCAP.dumpDot(graf, "test.dot")
using Printf
arg = Dict{String, Any}("w" => "w", "replacement" => "10")

for i in JuliaCAP.resiKolo(graf, arg)
	@printf("%s = %s\n", i[1], i[2])
end
# TODO
#NAPRAVITI LEP ISPIS JEDNACINA
#ZAOKRUZITI VREDNOSTI I OBRISATI -0
#PROVERITI GRESKE

# using NLsolve


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
