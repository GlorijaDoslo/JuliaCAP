include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

using Symbolics
using SymbolicUtils

Rx = Symbolics.Sym{Num}(Symbol("R"))

# PRIMER 9
dodajGranu(graf, Grana(Vg, "U", [4], [1], ["U"]))
dodajGranu(graf, Grana(R, "R1", [4], [3], [Rx]))
dodajGranu(graf, Grana(C, "C1", [3], [1], ["C"]))
dodajGranu(graf, Grana(C, "C2", [1], [2], ["C"]))
dodajGranu(graf, Grana(L, "L1", [2], [3], ["L"]))
dodajGranu(graf, Grana(R, "R2", [2], [1], [Rx]))

rezultat = resiKolo(graf, omega = "w")

Cx = Symbolics.Sym{Num}(Symbol("C"))
Lx = Symbolics.Sym{Num}(Symbol("L"))
subst = Dict(Cx => 1/Rx, Lx => 2*Rx)

a = Dict(rezultat)
Us = SymbolicUtils.simplify(Symbolics.substitute(a[Symbolics.Sym{Num}(Symbol("U2"))], subst))

Ugs = Symbolics.Sym{Num}(Symbol("U"))

Hjw = SymbolicUtils.simplify(Us / Ugs)
println("H(jw) = ", Hjw)

using Latexify
println(latexify(Hjw))
