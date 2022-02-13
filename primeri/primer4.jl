include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 4
dodajGranu(graf, Grana(Ig, "Ig1", [1], [2], ["Ig"]))
dodajGranu(graf, Grana(R, "R1", [2], [1], ["R1"]))
dodajGranu(graf, Grana(R, "R2", [2], [4], ["R2"]))
dodajGranu(graf, Grana(R, "R3", [1], [5], ["R3"]))
dodajGranu(graf, Grana(R, "R4", [5], [3], ["R4"]))
dodajGranu(graf, Grana(R, "R5", [2], [6], ["R5"]))
dodajGranu(graf, Grana(R, "R6", [1], [3], ["R6"]))
dodajGranu(graf, Grana(opAmp, "opAmp1", [6, 5], [3]))
dodajGranu(graf, Grana(C, "C1", [1], [2], ["C1"]))
dodajGranu(graf, Grana(C, "C2", [4], [3], ["C2"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

# a = Dict(rezultat)
#
# using Symbolics
#
# U3 = a[Symbolics.Sym{Num}(Symbol("U3"))]
# U = Symbolics.Sym{Num}(Symbol("U"))
#
# using SymbolicUtils
# println("A = ", SymbolicUtils.simplify(U3/U))

# using Latexify
# for (k, v) in rezultat
# 	println(latexify(k ~ v))
# end
#println()
# ispisi_specifican_rezultat(rezultat, "U2")
