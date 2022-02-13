include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 6
dodajGranu(graf, Grana(Vg,    "U",    [4],    [1],    ["U"]))
dodajGranu(graf, Grana(R,     "R1",   [2],    [4],    ["R1"]))
dodajGranu(graf, Grana(VCCS,  "VCCS", [2, 1], [3, 1], ["g1"]))
dodajGranu(graf, Grana(VCCS,  "VCCS", [3, 1], [3, 1], ["g2"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

a = Dict(rezultat)

using Symbolics

U3 = a[Symbolics.Sym{Num}(Symbol("U3"))]
U = Symbolics.Sym{Num}(Symbol("U"))

using SymbolicUtils
println("A = ", SymbolicUtils.simplify(U3/U))
