include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 5
dodajGranu(graf, Grana(Vg, "U", [2], [1], ["U"]))
dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))
dodajGranu(graf, Grana(R, "R2", [1], [5], ["R2"]))
dodajGranu(graf, Grana(R, "R3", [1], [4], ["R3"]))
dodajGranu(graf, Grana(C, "C1", [1], [4], ["C1"]))
dodajGranu(graf, Grana(CCCS,  "CCCS", [3, 1], [5, 1], ["a"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

a = Dict(rezultat)

using Symbolics

U2 = a[Symbolics.Sym{Num}(Symbol("U2"))]
R2 = Symbolics.Sym{Num}(Symbol("R2"))

using SymbolicUtils
println("P2 = ", SymbolicUtils.simplify(U2 * U2 / R2))
