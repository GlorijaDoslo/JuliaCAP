include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

using Symbolics
using SymbolicUtils

Rx = Symbolics.Sym{Num}(Symbol("R"))

# PRIMER 8
dodajGranu(graf, Grana(Vg,    "U",    [2],    [1],    ["U"]))
dodajGranu(graf, Grana(R,     "R1",   [1],    [3],    [Rx]))
dodajGranu(graf, Grana(R,     "R2",   [3],    [2],    [2*Rx]))

rezultat = resiKolo(graf, omega = "w")

for (k, v) in rezultat
	println(k, " = ", SymbolicUtils.simplify(v))
end

a = Dict(rezultat)

U3 = a[Symbolics.Sym{Num}(Symbol("U3"))]
U2 = a[Symbolics.Sym{Num}(Symbol("U2"))]

UR2 = SymbolicUtils.simplify(U2 - U3)

println("UR2 = ", UR2)

println("P3 = ", SymbolicUtils.simplify(UR2 * UR2 / (2 * Rx)))
