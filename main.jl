
#import .JuliaCAP
module Test
include("JuliaCap.jl")
using .JuliaCAP

graph = newGraph()

#Test1 (radi)
# addEdge(graph, Edge(Vg, "V1", [4], [1], [5.]))
# addEdge(graph, Edge(R, "R1", [4], [3], [150.]))
# addEdge(graph, Edge(R, "R2", [3], [2], [50.]))
# addEdge(graph, Edge(R, "R3", [2], [1], [300.]))

# addEdge(graph, Edge(Vg, "V1", [4], [1], ["V1"]))
# addEdge(graph, Edge(R, "R1", [4], [3], ["R1"]))
# addEdge(graph, Edge(R, "R2", [3], [2], ["R2"]))
# addEdge(graph, Edge(R, "R3", [2], [1], ["R3"]))

# @Symbolics.variables Ug Rp
# Ug = Symbolics.Sym{Symbolics.Num}(Symbol("Ug"))
# Rp = Symbolics.Sym{Symbolics.Num}(Symbol("Rp"))

# svi ovi testovi rade
# addEdge(graph, Edge(Vg, "V1", [3], [1], ["Ug"]))
# addEdge(graph, Edge(R, "R1", [2], [1], ["R1"]))
# addEdge(graph, Edge(R, "R2", [3], [2], ["R2"]))

# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.Vg, "V1", [2], [1], ["Ug"]))
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R1", [2], [1], ["R"]))
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R2", [2], [1], ["R"]))
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R3", [2], [1], ["R"]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], [3]))
# addEdge(graph, Edge(R, "R1", [2], [1], [100]))
# addEdge(graph, Edge(R, "R2", [2], [1], [100]))
# addEdge(graph, Edge(R, "R3", [2], [1], [100]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], [2]))
# addEdge(graph, Edge(R, "R1", [2], [3], [50]))
# addEdge(graph, Edge(R, "R2", [3], [1], [50]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], ["Ug"]))
# addEdge(graph, Edge(R, "R1", [2], [3], ["R"]))
# addEdge(graph, Edge(R, "R2", [3], [1], ["R"]))

# addEdge(graph, Edge(Vg, "V1", [2], [3], ["Ug"]))
# addEdge(graph, Edge(R, "R1", [2], [1], ["R1"]))
# addEdge(graph, Edge(R, "R2", [3], [1], ["R2"]))


#Test2 (radi)


# addEdge(graph, Edge(Vg, "V1", [2], [1], [5.])) #5
# addEdge(graph, Edge(R, "R1", [2], [3], [514.]))#514
# addEdge(graph, Edge(R, "R2", [3], [4], [123.]))#123
# addEdge(graph, Edge(R, "R3", [4], [5], [300.]))#300
# addEdge(graph, Edge(R, "R4", [5], [1], [154.]))#154


# radi
# addEdge(graph, Edge(Vg, "V1", [2], [1], [28])) #5
# addEdge(graph, Edge(Vg, "V2", [4], [1], [7])) #5
# addEdge(graph, Edge(R, "R1", [2], [3], [4]))#514
# addEdge(graph, Edge(R, "R2", [3], [4], [1]))#123
# addEdge(graph, Edge(R, "R3", [3], [1], [2]))#300
# addEdge(graph, Edge(R, "R4", [5], [1], ["R4"]))#154

#Test3 (ne radi kad dodas simplify, ni kad se dodaju dva simplify-a)
# ali radi bez simplify-a
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.Vg, "V1", [5], [1], ["V1"]))#5
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R1", [5], [2], ["R1"]))#150
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R3", [2], [1], ["R3"]))#50
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R4", [2], [3], ["R4"]))#200
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R5", [4], [3], ["R5"]))#50
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.R, "R6", [3], [1], ["R6"]))#100
# JuliaCAP.addEdge(graph, JuliaCAP.Edge(JuliaCAP.VCCS, "VCCS1", [2, 1], [4, 1], ["g"]))#1

# addEdge(graph, Edge(Vg, "V1", [5], [1], [5.]))#5
# addEdge(graph, Edge(R, "R1", [5], [2], [150.]))#150
# addEdge(graph, Edge(R, "R3", [2], [1], [50.]))#50
# addEdge(graph, Edge(R, "R4", [2], [3], [200.]))#200
# addEdge(graph, Edge(R, "R5", [4], [3], [50.]))#50
# addEdge(graph, Edge(R, "R6", [3], [1], [100.]))#100
# addEdge(graph, Edge(VCCS, "VCCS1", [2, 1], [4, 1], [1.]))#1

#Test4 (radi)
# addEdge(graph, Edge(Vg, "V1", [6], [1], [2.5]))#2.5
# addEdge(graph, Edge(Vg, "V2", [2], [1], [2]))#2
# addEdge(graph, Edge(R, "R5", [1], [4], [10000]))#10000
# addEdge(graph, Edge(R, "R6", [2], [3], [10000]))#10000
# addEdge(graph, Edge(R, "R7", [3], [6], [2780]))#2780
# addEdge(graph, Edge(R, "R8", [4], [5], [2780]))#2780
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))

# addEdge(graph, Edge(Vg, "V1", [6], [1], ["V1"]))#2.5
# addEdge(graph, Edge(Vg, "V2", [2], [1], ["V2"]))#2
# addEdge(graph, Edge(R, "R5", [1], [4], ["R5"]))#10000
# addEdge(graph, Edge(R, "R6", [2], [3], ["R6"]))#10000
# addEdge(graph, Edge(R, "R7", [3], [6], ["R7"]))#2780
# addEdge(graph, Edge(R, "R8", [4], [5], ["R8"]))#2780
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))

#Test6
# addEdge(graph, Edge(Vg, "V1", [2], [1], [3.]))
# addEdge(graph, Edge(R, "R1", [2], [3], [50.]))
# addEdge(graph, Edge(R, "R2", [3], [4], [100.]))
# addEdge(graph, Edge(C, "C1", [4], [1], [5.], [2.]))

#Isto test6 samo sto su parametri nekih elemenata zamenjeni opstim simbolima
# ne radi kad ima simplify koji je unutar solvera
# addEdge(graph, Edge(Vg, "V1", [2], [1], ["V1"]))
# addEdge(graph, Edge(R, "R1", [2], [3], ["R1"]))
# addEdge(graph, Edge(R, "R2", [3], [4], ["R2"]))
# addEdge(graph, Edge(C, "C1", [4], [1], ["C"], ["U0"]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], [3.]))
# addEdge(graph, Edge(R, "R1", [2], [3], [50.]))
# addEdge(graph, Edge(C, "C1", [3], [1], [5.], [2.]))
# addEdge(graph, Edge(L, "L1", [4], [1], [5.], [2.]))

# radi sa dva simplify-a
# addEdge(graph, Edge(Vg, "V1", [5], [1], [3.]))
# addEdge(graph, Edge(R, "R1", [5], [2], [50.]))
# addEdge(graph, Edge(C, "C1", [3], [1], [5.], [2.]))
# addEdge(graph, Edge(C, "C2", [4], [1], [5.], [2.]))
# addEdge(graph, Edge(VCCS,  "VCCS1", [2, 1], [3, 1], [1]))#a
# addEdge(graph, Edge(VCCS,  "VCCS2", [3, 1], [3, 1], [1]))#a
# addEdge(graph, Edge(VCCS,  "VCCS3", [3, 1], [4, 1], [1]))#a
# addEdge(graph, Edge(VCCS,  "VCCS4", [4, 1], [1, 3], [1]))#a

# addEdge(graph, Edge(Vg, "V1", [5], [1], ["V1"]))
# addEdge(graph, Edge(R, "R1", [5], [2], ["R1"]))
# addEdge(graph, Edge(C, "C1", [3], [1], ["C1"], ["U01"]))
# addEdge(graph, Edge(C, "C2", [4], [1], ["C2"], ["U02"]))
# addEdge(graph, Edge(VCCS,  "VCCS1", [2, 1], [3, 1], ["a"]))#a
# addEdge(graph, Edge(VCCS,  "VCCS2", [3, 1], [3, 1], ["a"]))#a
# addEdge(graph, Edge(VCCS,  "VCCS3", [3, 1], [4, 1], ["a"]))#a
# addEdge(graph, Edge(VCCS,  "VCCS4", [4, 1], [1, 3], ["a"]))#a

# ne radi sa dva simplify-a, ali radi bez simplify
# addEdge(graph, Edge(Vg, "V1", [2], [1], [3.]))
# addEdge(graph, Edge(R, "R1", [5], [1], [50.]))
# addEdge(graph, Edge(R, "R3", [6], [3], [50.]))
# addEdge(graph, Edge(R, "R4", [3], [4], [50.]))
# addEdge(graph, Edge(R, "R5", [2], [4], [50.]))
# addEdge(graph, Edge(opAmp, "opAmp1", [2, 5], [6]))
# addEdge(graph, Edge(opAmp, "opAmp2", [2, 3], [4]))
# addEdge(graph, Edge(C, "C2", [5], [6], [5.], [2.]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], ["V1"]))
# addEdge(graph, Edge(R, "R1", [5], [1], ["R1"]))
# addEdge(graph, Edge(R, "R3", [6], [3], ["R3"]))
# addEdge(graph, Edge(R, "R4", [3], [4], ["R4"]))
# addEdge(graph, Edge(R, "R5", [2], [4], ["R5"]))
# addEdge(graph, Edge(opAmp, "opAmp1", [2, 5], [6]))
# addEdge(graph, Edge(opAmp, "opAmp2", [2, 3], [4]))
# addEdge(graph, Edge(C, "C2", [5], [6], ["C2"], ["U02"]))

#Test7 (radi sa dva simplify-a)

# addEdge(graph, Edge(Vg, "V1", [2], [1], [3.]))
# addEdge(graph, Edge(R, "R1", [2], [3], [50.]))
# addEdge(graph, Edge(R, "R2", [3], [4], [100.]))
# addEdge(graph, Edge(L, "L1", [4], [1], [5.], [2.]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], ["V1"]))
# addEdge(graph, Edge(R, "R1", [2], [3], ["R1"]))
# addEdge(graph, Edge(R, "R2", [3], [4], ["R2"]))
# addEdge(graph, Edge(L, "L1", [4], [1], ["L1"], ["I01"]))

#Test9 (ne radi sa dva simplify-a)
# addEdge(graph, Edge(Vg, "V1", [2], [1], ["V1"]))#5
# addEdge(graph, Edge(R, "R1", [4], [5], ["R1"]))#10000
# addEdge(graph, Edge(R, "R2", [5], [6], ["R2"]))#10000
# addEdge(graph, Edge(R, "R3", [2], [3], ["R3"]))#10000
# addEdge(graph, Edge(C, "C1", [3], [4], ["C1"], ["Uo"]))#3
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 1], [6]))
# addEdge(graph, Edge(opAmp, "opAmp2", [1, 5], [4]))
# addEdge(graph, Edge(R, "R4", [6], [1], ["R4"]))

# Test 10 (radi sa dva simplify-a)
# addEdge(graph, Edge(Vg, "V1", [2], [1], ["V1"]))#5
# addEdge(graph, Edge(R, "R1", [4], [1], ["R1"]))#10000
# addEdge(graph, Edge(R, "R2", [4], [5], ["R2"]))#10000
# addEdge(graph, Edge(R, "R3", [5], [1], ["R3"]))#10000
# addEdge(graph, Edge(R, "R4", [2], [3], ["R4"]))#10000
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], [5]))#5
# addEdge(graph, Edge(R, "R1", [4], [1], [10000]))#10000
# addEdge(graph, Edge(R, "R2", [4], [5], [10000]))#10000
# addEdge(graph, Edge(R, "R3", [5], [1], [10000]))#10000
# addEdge(graph, Edge(R, "R4", [2], [3], [10000]))#10000
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))

# Test 11 (T - sema) -> radi sa dva simplify-a
# addEdge(graph, Edge(Vg, "V1", [2], [1], [5]))#5
# addEdge(graph, Edge(R, "R1", [2], [3], [10000]))#10000
# addEdge(graph, Edge(R, "R2", [3], [6], [10000]))#10000
# addEdge(graph, Edge(R, "R3", [6], [1], [10000]))#10000
# addEdge(graph, Edge(R, "R4", [6], [5], [10000]))#10000
# addEdge(graph, Edge(R, "R5", [4], [1], [10000]))#10000
# addEdge(graph, Edge(R, "R6", [5], [1], [10000]))#10000
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))

# addEdge(graph, Edge(Vg, "V1", [2], [1], ["V1"]))#5
# addEdge(graph, Edge(R, "R1", [2], [3], ["R1"]))#10000
# addEdge(graph, Edge(R, "R2", [3], [6], ["R2"]))#10000
# addEdge(graph, Edge(R, "R3", [6], [1], ["R3"]))#10000
# addEdge(graph, Edge(R, "R4", [6], [5], ["R4"]))#10000
# addEdge(graph, Edge(R, "R5", [4], [1], ["R5"]))#10000
# addEdge(graph, Edge(R, "R6", [5], [1], ["R6"]))#10000
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))

# Test 12 (radi bez substitute, ali sa njim ne radi), u Linuxu ne radi, ne radi na win 7
# addEdge(graph, Edge(Ig, "Ig1", [1], [2], ["Ig1"]))#5
# addEdge(graph, Edge(Ig, "Ig2", [4], [3], ["Ig2"]))#5
# addEdge(graph, Edge(R, "R1", [5], [6], ["R1"]))#10000
# addEdge(graph, Edge(R, "R2", [4], [1], ["R2"]))#10000
# addEdge(graph, Edge(R, "R3", [2], [5], ["R3"]))#10000
# addEdge(graph, Edge(R, "R4", [6], [3], ["R4"]))#10000
# addEdge(graph, Edge(opAmp, "opAmp1", [2, 6], [3]))
# addEdge(graph, Edge(opAmp, "opAmp2", [4, 6], [5]))

# Isto test 12 radi bez substitute, ali sa njim ne radi
# addEdge(graph, Edge(Ig, "Ig1", [1], [2], [5.]))#5
# addEdge(graph, Edge(Ig, "Ig2", [4], [3], [5.]))#5
# addEdge(graph, Edge(R, "R1", [5], [6], [10000.]))#10000
# addEdge(graph, Edge(R, "R2", [4], [1], [10000.]))#10000
# addEdge(graph, Edge(R, "R3", [2], [5], [10000.]))#10000
# addEdge(graph, Edge(R, "R4", [6], [3], [10000.]))#10000
# addEdge(graph, Edge(opAmp, "opAmp1", [2, 6], [3]))
# addEdge(graph, Edge(opAmp, "opAmp2", [4, 6], [5]))

# Test 13 (radi bez oba simplify-a, ali sa jednim ili dva ne radi)
# addEdge(graph, Edge(Vg, "V1", [4], [1], ["V1"]))#5
# addEdge(graph, Edge(R, "R1", [4], [2], ["R1"]))#10000
# addEdge(graph, Edge(R, "R2", [2], [3], ["R2"]))#10000
# addEdge(graph, Edge(InductiveT, "T1", [2, 1], [3, 1], ["L1", "L2", "L12"], ["I01", "I02"]))

# Test 14 (radi sa jednim i nijednim simplify, a sa dva ne radi)
addEdge(graph, Edge(Vg, "V1", [4], [1], ["V1"]))#5
addEdge(graph, Edge(R, "R1", [4], [2], ["Zc"]))#10000
addEdge(graph, Edge(R, "R2", [3], [1], ["Zc"]))#10000
addEdge(graph, Edge(T, "T1", [2, 1], [3, 1], ["Zc", "tau"]))#10000

# ovo nije test primer
#addEdge(graph, Edge(R, "R4", [3], [4], [200.]))
#addEdge(graph, Edge(R, "R5", [5], [4], [50.]))
#addEdge(graph, Edge(R, "R6", [4], [1], [100.]))
#addEdge(graph, Edge(VCVS,  "VCVS", [2, 1], [4, 1], 1))#a
#addEdge(graph, Edge(CCVS,  "CCVS", [3, 1], [5, 1], 2.))#r
#addEdge(graph, Edge(VCCS,  "VCCS", [3, 1], [5, 1], 1.))#g
#addEdge(graph, Edge(CCCS,  "CCCS", [3, 1], [5, 1], [5.]))#a
# addEdge(graph, Edge(opAmp, "opAmp1", [3, 4], [5]))



# dumpDot(graph, "test.dot")
#
#arg = Dict{String, Any}("w" => "", "replacement" => "10")
arg = Dict{String, Any}("w" => "")
result = solveCircuit(graph, arg)
printCircuitSpecifications(graph)
printEquations()
println("*****SOLUTION*****")
#printLatexEquations()
printResults(result)

#printLatexResults(result)
#printLatexSpecificResult(result, "U2")
#println()
# printSpecificResult(result, "U2")
#printCircuitSpecifications(graph)
end