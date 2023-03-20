module JuliaCAP

export Edge, Graph, newGraph, addEdge, solveCircuit, printResults, printSpecificResult, printLatexResults
export printLatexSpecificResult, printCircuitSpecifications, printEquations, printLatexEquations
export TypeOfEdge, R, Vg, Ig, opAmp, VCVS, VCCS, CCCS, CCVS, L, C, IdealT, InductiveT, ABCD, Z, Y, T

using Symbolics
using SymbolicUtils
using Latexify
using Printf

@enum TypeOfEdge R Vg Ig opAmp VCVS VCCS CCCS CCVS L C IdealT InductiveT ABCD Z Y T

#T is transmission line
j = Symbolics.Sym{Num}(Symbol("j"))
equations = Vector{Equation}();
symbolsVect = Vector{Symbolics.Sym{Num}}()
timeDomain = false
shifts = Dict()


struct Edge
	type :: TypeOfEdge
	name :: String
	node1 :: Vector{Int}
	node2 :: Vector{Int}
	param :: Vector{}
	currentOrVoltage :: Vector{}
	function Edge(t :: TypeOfEdge, i :: String, c1 :: Vector{Int}, c2 :: Vector{Int}, p :: Vector{} = Vector{}()
		, st :: Vector{} = Vector{}())
		#push!(st, 0)
		#push!(p, 0)
		return new(t, i, c1, c2, p, st)
	end

end

problem = false

mutable struct Graph
	nodeEquations 		:: Vector{Equation}
	edgeEquations   	:: Vector{Equation}
	edges            	:: Vector{Edge}
	maxNode          	:: Int

end

function newGraph()
	return Graph(Vector{Num}(), Vector{Num}(), Vector{Edge}(), 0)
end

function addEdge(graph :: Graph, edge :: Edge)
	for j in edge.node1
		if j > graph.maxNode
			graph.maxNode = j
		end
	end
	for j in edge.node2
		if j > graph.maxNode
			graph.maxNode = j
		end
	end
	push!(graph.edges, edge)
end

function dumpDot(graph :: Graph, file :: String)
	open(file, "w") do file
		write(file, "graph g {\n")
		for g in graph.edges
			write(file, "	" * string(g.node1[1]) * " -- "
				  * string(g.node2[1]) * " [label = \"" * g.name * "\"];\n")
		end
		write(file, "}")
	end
end

function solveCircuit(graph :: Graph, args :: Dict)
	graph.nodeEquations = Vector{Equation}(undef, graph.maxNode)
	t = Vector{Num}(undef, graph.maxNode)
	for i in 1:length(t)
		t[i] = 0
	end
	graph.edgeEquations = Vector{Equation}()

	######### Reading omega and replacement ##########
	omega = ""
	for a in keys(args)	#list of keys
		if a == "w" || a == "omega"
			omega = args[a]
		end
		if a == "replacement" || a == "r"
			replacementRule = args[a]
		end
	end

	if omega == ""
		timeDomain = false
		s = Symbolics.Sym{Num}(Symbol("s"))
	else
		timeDomain = true
		if omega isa String
			s = Symbolics.Sym{Num}(Symbol("j" * string(omega)))
		else
			s = j * omega
		end
	end
	symbols = Set{Symbolics.Sym{Num}}()	# its type is Set because we don't want duplicates
	id = 1


	for g in graph.edges
	
		if g.type == R
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U2)
			end

			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1
			I = (U1 - U2) * G
			# check if it is symbol or number
			if g.param isa Vector{String}
				push!(shifts, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
			else
				push!(shifts, G => 1 / g.param[1])
				# I = (U1 - U2) / g.param[1]
			end

			t[g.node1[1]] += I
			t[g.node2[1]] -= I

		elseif g.type == Vg
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U2)
			end
			Iug = Symbolics.Sym{Num}(Symbol("I" * g.name))
			push!(symbols, Iug)
			t[g.node1[1]] += Iug
			t[g.node2[1]] -= Iug

			#provera da li je simbol ili broj
			if g.param isa Vector{String}
				Eq = U1 - U2 ~ Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				Eq = U1 - U2 ~ g.param[1]
			end

			push!(graph.edgeEquations, Eq)

		elseif g.type == Ig
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U2)
			end


			if g.param isa Vector{String}
				t[g.node1[1]] += Symbolics.Sym{Num}(Symbol(g.param[1]))
				t[g.node2[1]] -= Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				t[g.node1[1]] += g.param[1]
				t[g.node2[1]] -= g.param[1]
			end

		elseif g.type == opAmp

			IopAmp = Symbolics.Sym{Num}(Symbol("I" * g.name))
			push!(symbols, IopAmp)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end

			t[g.node2[1]] += IopAmp
			Eq = U1 - U2 ~ 0
			push!(graph.edgeEquations, Eq)

		elseif g.type == VCVS
			# g.param is amplification(voltage gain)
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name))
			push!(symbols, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			t[g.node2[1]] += I1
			t[g.node2[2]] -= I1
			if g.param isa Vector{String}
				Eq = U3 - U4 - Symbolics.Sym{Num}(Symbol(g.param[1])) * (U1 - U2) ~ 0
			else
				Eq = U3 - U4 - g.param[1] * (U1 - U2) ~ 0
			end
			push!(graph.edgeEquations, Eq)

		elseif g.type == VCCS
			#g.param is transconductance
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			if g.param isa Vector{String}
				t[g.node2[1]] += Symbolics.Sym{Num}(Symbol(g.param[1])) * (U1 - U2)
				t[g.node2[2]] -= Symbolics.Sym{Num}(Symbol(g.param[1])) * (U1 - U2)
			else
				t[g.node2[1]] += g.param[1] * (U1 - U2)
				t[g.node2[2]] -= g.param[1] * (U1 - U2)
			end

		elseif g.type == CCCS
			# g.param is amplification(current gain)
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name))
			push!(symbols, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end

			t[g.node1[1]] += I1
			t[g.node1[2]] -= I1
			if g.param isa Vector{String}
				t[g.node2[1]] += Symbolics.Sym{Num}(Symbol(g.param[1])) * I1
				t[g.node2[2]] -= Symbolics.Sym{Num}(Symbol(g.param[1])) * I1
			else
				t[g.node2[1]] += g.param[1] * I1
				t[g.node2[2]] -= g.param[1] * I1
			end

			Eq = U1 - U2 ~ 0
			push!(graph.edgeEquations, Eq)

		elseif g.type == CCVS
			#g.param is transresistance
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name))
			push!(symbols, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1
			I = (U3 - U4) * G

			if g.param isa Vector{String}
				push!(shifts, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
			else
				push!(shifts, G => 1 / g.param[1])
			end

			#t[g.node1[1]] += (U3 - U4) / g.param[1]
			#t[g.node1[2]] -= (U3 - U4) / g.param[1]
			t[g.node1[1]] += I
			t[g.node1[2]] -= I

			t[g.node2[1]] += I1
			t[g.node2[2]] -= I1

			Eq = U1 - U2 ~ 0
			push!(graph.edgeEquations, Eq)

		elseif g.type == L
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U2)
			end
			#I = 0
			if isempty(g.currentOrVoltage)
				push!(g.currentOrVoltage, 0)
			end

			S1 = Symbolics.Sym{Num}(Symbol("S" * string(id)))
			id += 1
			S2 = Symbolics.Sym{Num}(Symbol("S" * string(id)))
			id += 1

			if g.currentOrVoltage isa Vector{String}
				I1 = (U1 - U2) * S1 + Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1])) * S2
				I2 = (U2 - U1) * S1 - Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1])) * S2

				if g.param isa Vector{String}
					push!(shifts, S1 => 1 / (Symbolics.Sym{Num}(Symbol(g.param[1])) * s))
					push!(shifts, S2 => 1 / s)
				else
					push!(shifts, S2 => 1 / s)
					I1 = (U1 - U2) * S2 / g.param[1] + Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1])) * S2
					I2 = (U2 - U1) * S2 / g.param[1] - Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1])) * S2
				end

			else
				I1 = (U1 - U2) * S1 + g.currentOrVoltage[1] * S2
				I2 = (U2 - U1) * S1 - g.currentOrVoltage[1] * S2

				if g.param isa Vector{String}
					push!(shifts, S1 => 1 / (Symbolics.Sym{Num}(Symbol(g.param[1])) * s))
					push!(shifts, S2 => 1 / s)
				else
					push!(shifts, S2 => 1 / s)
					I1 = (U1 - U2) * S2 / g.param[1] + g.currentOrVoltage[1] * S2
					I2 = (U2 - U1) * S2 / g.param[1] - g.currentOrVoltage[1] * S2
				end
			end

			#t[g.node1[1]] += (U1 - U2) / (s * g.param[1]) + g.currentOrVoltage[1] / s
			#t[g.node2[1]] += (U2 - U1) / (s * g.param[1]) - g.currentOrVoltage[1] / s
			t[g.node1[1]] += I1
			t[g.node2[1]] += I2

		elseif g.type == C
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U2)
			end

			if isempty(g.currentOrVoltage)
				push!(g.currentOrVoltage, 0)
			end

			if (g.currentOrVoltage isa Vector{String} && g.param isa Vector{String})
				par = Symbolics.Sym{Num}(Symbol(g.param[1]))
				currOrVol = Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1]))
				t[g.node1[1]] += (U1 - U2) * s * par - currOrVol * par
				t[g.node2[1]] += (U2 - U1) * s * par + currOrVol * par
			elseif g.currentOrVoltage isa Vector{String}
				currOrVol = Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1]))
				t[g.node1[1]] += (U1 - U2) * s * g.param[1] - currOrVol * g.param[1]
				t[g.node2[1]] += (U2 - U1) * s * g.param[1] + currOrVol * g.param[1]
			elseif g.param isa Vector{String}
				par = Symbolics.Sym{Num}(Symbol(g.param[1]))
				t[g.node1[1]] += (U1 - U2) * s * par - g.currentOrVoltage[1] * par
				t[g.node2[1]] += (U2 - U1) * s * par + g.currentOrVoltage[1] * par
			else
				t[g.node1[1]] += (U1 - U2) * s * g.param[1] - g.currentOrVoltage[1] * g.param[1]
				t[g.node2[1]] += (U2 - U1) * s * g.param[1] + g.currentOrVoltage[1] * g.param[1]
			end

		elseif g.type == IdealT

			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name))
			push!(symbols, I1)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			t[g.node1[1]] += I1
			t[g.node1[2]] -= I1
			if g.param isa Vector{String}
				t[g.node2[1]] += -Symbolics.Sym{Num}(Symbol(g.param[1])) * I1
				t[g.node2[2]] -= Symbolics.Sym{Num}(Symbol(g.param[1])) * I1

				Eq = (U1 - U2) - Symbolics.Sym{Num}(Symbol(g.param[1])) * (U3 - U4) ~ 0
			else
				t[g.node2[1]] += -g.param[1] * I1
				t[g.node2[2]] -= g.param[1] * I1

				Eq = (U1 - U2) - g.param[1] * (U3 - U4) ~ 0
			end
			push!(graph.edgeEquations, Eq)

		elseif g.type == InductiveT
			# L1, L2, L12, I01, I02
			
			if isempty(g.currentOrVoltage)
				push!(g.currentOrVoltage, 0)
				if length(g.currentOrVoltage) == 1
					push!(g.currentOrVoltage, 0)
				end
			end

			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node1[1])))
			push!(symbols, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node2[1])))
			push!(symbols, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			t[g.node1[1]] += I1
			t[g.node1[2]] -= I1
			t[g.node2[1]] += I2
			t[g.node2[2]] -= I2

			if (g.param isa Vector{String} && !(g.currentOrVoltage isa Vector{String}))
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				par3 = Symbolics.Sym{Num}(Symbol(g.param[3]))
				Eq = U1 - U2 - (par1 * s * I1 - par1 * g.currentOrVoltage[1] + par3 * s * I2 - par3 * g.currentOrVoltage[2]) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = U3 - U4 - (par3 * s * I1 - par3 * g.currentOrVoltage[1] + par2 * s * I2 - par2 * g.currentOrVoltage[2]) ~ 0
				push!(graph.edgeEquations, Eq)

			elseif (g.currentOrVoltage isa Vector{String} && !(g.param isa Vector{String}))
				str1 = Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1]))
				str2 = Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[2]))
				Eq = U1 - U2 - (g.param[1] * s * I1 - g.param[1] * str1 + g.param[3] * s * I2 - g.param[3] * str2) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = U3 - U4 - (g.param[3] * s * I1 - g.param[3] * str1 + g.param[2] * s * I2 - g.param[2] * str2) ~ 0
				push!(graph.edgeEquations, Eq)

			elseif (g.param isa Vector{String} && g.currentOrVoltage isa Vector{String})
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				par3 = Symbolics.Sym{Num}(Symbol(g.param[3]))
				str1 = Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[1]))
				str2 = Symbolics.Sym{Num}(Symbol(g.currentOrVoltage[2]))

				Eq = U1 - U2 - (par1 * s * I1 - par1 * str1 + par3 * s * I2 - par3 * str2) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = U3 - U4 - (par3 * s * I1 - par3 * str1 + par2 * s * I2 - par2 * str2) ~ 0
				push!(graph.edgeEquations, Eq)
			else
				Eq = U1 - U2 - (g.param[1] * s * I1 - g.param[1] * g.currentOrVoltage[1] + g.param[3] * s * I2 - g.param[3] * g.currentOrVoltage[2]) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = U3 - U4 - (g.param[3] * s * I1 - g.param[3] * g.currentOrVoltage[1] + g.param[2] * s * I2 - g.param[2] * g.currentOrVoltage[2]) ~ 0
				push!(graph.edgeEquations, Eq)
			end

		elseif g.type == ABCD
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node1[1])))
			push!(symbols, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node2[1])))
			push!(symbols, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			t[g.node1[1]] += I1
			t[g.node1[2]] -= I1
			t[g.node2[1]] -= I2
			t[g.node2[2]] += I2

			if g.param isa Vector{String}
				Eq = U1 - U2 - (Symbolics.Sym{Num}(Symbol(g.param[1])) * U3 - U4 + Symbolics.Sym{Num}(Symbol(g.param[2])) * I2) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = I1 - (Symbolics.Sym{Num}(Symbol(g.param[3])) * U3 - U4 + Symbolics.Sym{Num}(Symbol(g.param[4])) * I2) ~ 0
				push!(graph.edgeEquations, Eq)
			else
				Eq = U1 - U2 - (g.param[1] * U3 - U4 + g.param[2] * I2) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = I1 - (g.param[3] * U3 - U4 + g.param[4] * I2) ~ 0
				push!(graph.edgeEquations, Eq)
			end

		elseif g.type == Z
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end

			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1
			# check if it is a symbol or number
			if g.param isa Vector{String}
				push!(shifts, G => 1 / Symbolics.Sym{Num}(Symbol(g.param[1])))
			else
				push!(shifts, G => 1 / g.param[1])
			end

			t[g.node1[1]] += (U1 - U2) * G
			t[g.node2[1]] -= (U1 - U2) * G

		elseif g.type == Y
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end

			if g.param isa Vector{String}
				t[g.node1[1]] += (U1 - U2) * Symbolics.Sym{Num}(Symbol(g.param[1]))
				t[g.node2[1]] -= (U1 - U2) * Symbolics.Sym{Num}(Symbol(g.param[1]))
			else
				t[g.node1[1]] += (U1 - U2) * g.param[1]
				t[g.node2[1]] -= (U1 - U2) * g.param[1]
			end

		elseif (g.type == T && timeDomain == true)					#####################   UNFINISHED
			#Zc, theta -> g.param
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node1[1])))
			push!(symbols, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node2[1])))
			push!(symbols, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			t[g.node1[1]] += I1
			t[g.node1[2]] -= I1
			t[g.node2[1]] -= I2
			t[g.node2[2]] += I2
			G = Symbolics.Sym{Num}(Symbol("G" * string(id)))
			id += 1

			# global const im = j
			if g.param isa Vector{String}
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				push!(shifts, G => 1 / par1)
				Eq = U1 - U2 - (cos(par2) * (U3 - U4) + j * par1 * sin(par2) * I2) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = I1 - (j * G * sin(par2) * (U3 - U4) + cos(par2) * I2) ~ 0
				push!(graph.edgeEquations, Eq)
			else
				push!(shifts, G => 1 / g.param[1])
				Eq = U1 - U2 - (cos(g.param[2]) * (U3 - U4) + j * g.param[1] * sin(g.param[2]) * I2) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = I1 - (j * G * sin(g.param[2]) * (U3 - U4) + cos(g.param[2]) * I2) ~ 0
				push!(graph.edgeEquations, Eq)
			end

		elseif (g.type == T && timeDomain == false)
			#Zc, tau -> g.param
			I1 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node1[1])))
			push!(symbols, I1)
			I2 = Symbolics.Sym{Num}(Symbol("I" * g.name * string(g.node2[1])))
			push!(symbols, I2)
			U1 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[1])))
			if g.node1[1] != 1
				push!(symbols, U1)
			end
			U2 = Symbolics.Sym{Num}(Symbol("U" * string(g.node1[2])))
			if g.node1[2] != 1
				push!(symbols, U2)
			end
			U3 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[1])))
			if g.node2[1] != 1
				push!(symbols, U3)
			end
			U4 = Symbolics.Sym{Num}(Symbol("U" * string(g.node2[2])))
			if g.node2[2] != 1
				push!(symbols, U4)
			end

			t[g.node1[1]] += I1
			t[g.node1[2]] -= I1
			t[g.node2[1]] += I2
			t[g.node2[2]] -= I2
			if g.param isa Vector{String}
				par1 = Symbolics.Sym{Num}(Symbol(g.param[1]))
				par2 = Symbolics.Sym{Num}(Symbol(g.param[2]))
				Eq = U1 - U2 - (par1 * I1 + par1 * I2 * exp(-par2 * s) + (U3 - U4) * exp(-par2 * s)) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = U3 - U4 - (par1 * I2 + par1 * I1 * exp(-par2 * s) + (U1 - U2) * exp(-par2 * s)) ~ 0
				push!(graph.edgeEquations, Eq)
			else
				Eq = U1 - U2 - (g.param[1] * I1 + g.param[1] * I2 * exp(-g.param[2] * s) + (U3 - U4) * exp(-g.param[2] * s)) ~ 0
				push!(graph.edgeEquations, Eq)

				Eq = U3 - U4 - (g.param[1] * I2 + g.param[1] * I1 * exp(-g.param[2] * s) + (U1 - U2) * exp(-g.param[2] * s)) ~ 0
				push!(graph.edgeEquations, Eq)
			end
		end
	end

	for i in 1:length(graph.nodeEquations)
		graph.nodeEquations[i] = t[i] ~ 0
	end

	# equations = Vector{Equation}();

	# t = Symbolics.Sym{Num}(Symbol("U1")) ~ 0
	# push!(equations, t)

	append!(equations, graph.edgeEquations)
	append!(equations, graph.nodeEquations[2:(end)])

	# symbolsVect = Vector{Symbolics.Sym{Num}}()


	# for i in equations
	# 	println(i)
	# end

	for i in symbols
		push!(symbolsVect, i)
	end


	U1 = Symbolics.Sym{Symbolics.Num}(Symbol("U1"))
	for (i, val) in enumerate(equations)
		equations[i] = Symbolics.Equation(Symbolics.substitute(val.lhs, Dict([U1 => 0])),
										  Symbolics.substitute(val.rhs, Dict([U1 => 0])))
		# equations[i] = Symbolics.simplify(equations[i], expand=true)
	end
	
	res2 = Vector{Any}()
	ret = Vector{Tuple{Symbolics.Sym{Num}, Num}}()

	a, b = Symbolics.linear_expansion(equations, symbolsVect)

	if isempty(a)
		println("Solution doesn't exists!")
		return ret
	end

	D = Symbolics.det(a)

	if isequal(D, 0)
		println("Solution doesn't exists!") 
		return ret
	end
	
	# for i in equations[1:(end)]
	# 	println(Symbolics.substitute(i, shifts))
	# 	#println(i)
	# end

	# print("Symbols: ")
	# for i in symbols
	#  	print(i, " ")
	# end
	# println()

	res = Symbolics.solve_for(equations, symbolsVect)
	#res = Symbolics.simplify(res)
	if isempty(res) 
		problem = true
	end

	for i in res
		push!(res2, i)
	end

	for (i, val) in enumerate(res2)
		#SymPy.simplify(res[i]);

		#res2[i] = Symbolics.substitute(val, shifts)
		#res[i] = Symbolics.simplify(val)
		res2[i] = Symbolics.substitute(val, shifts)

	end

	for i in zip(symbolsVect, res2)
		push!(ret, i)
	end

	return ret

end

function printEquations()
	for i in equations
		println(Symbolics.substitute(i, shifts))
	end
end

function printLatexEquations()
	for i in equations
		println(latexify(Symbolics.substitute(i, shifts)))
	end
end

function printResults(res)
	for i in res
		if problem
			println("Solution doesn't exists!")
		end
		@printf("%s = %s\n", i[1], i[2])
		#display(i)
	end
end

function printLatexResults(res)
	for (k, v) in res
		println(latexify(k ~ v))
	end
end

function printSpecificResult(res, par)
	for i in res
		if par == string(i[1])
			@printf("%s = %s\n", i[1], i[2])
		end
	end
end

function printLatexSpecificResult(res, par)
	for (k,v) in res
		if par == string(k)
			println(latexify(k ~ v))
		end
	end
end

function printCircuitSpecifications(graph)
	println("Circuit Specifications: ")
	println("Number of nodes: ", graph.maxNode)
	print("Entered elements: ")
	for i in graph.edges
		print(i.type, " ")
	end
	println()
	# println("Replacement rule: ",self.replacementRule)
	println("Equations: ")
	for i in equations
		println(i)
	end
	println("Variables: ")
	for i in symbolsVect
		print(i, " ")
	end
	println()
	if timeDomain
		print("Frequency: ")
		println(-s)
	end
end

end
