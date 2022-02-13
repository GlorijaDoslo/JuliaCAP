include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 3
dodajGranu(graf, Grana(Vg, "U", [2], [1], ["U"]))
dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))
dodajGranu(graf, Grana(R, "R2", [1], [3], ["R2"]))
dodajGranu(graf, Grana(R, "R3", [3], [4], ["R3"]))
dodajGranu(graf, Grana(C, "C1", [1], [4], ["C1"]))
dodajGranu(graf, Grana(C, "C2", [5], [3], ["C2"]))
dodajGranu(graf, Grana(opAmp, "opAmp1", [4, 5], [5]))

using Symbolics

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

# a = Dict(rezultat)
#
# using Symbolics
#
# U4 = a[Symbolics.Sym{Num}(Symbol("U4"))]
# R4 = Symbolics.Sym{Num}(Symbol("R4"))
#
# using SymbolicUtils
# println("P4 = ", SymbolicUtils.simplify(U4 * U4 / R4))
