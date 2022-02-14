include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

using Symbolics
using SymbolicUtils

Rx = Symbolics.Sym{Num}(Symbol("R"))

# PRIMER 9
dodajGranu(graf, Grana(Vg, "U", [2], [1], ["U"]))
dodajGranu(graf, Grana(R,  "R", [2], [3], [Rx]))
dodajGranu(graf, Grana(C,  "C", [3], [1], ["C"]))

rezultat = resiKolo(graf, omega = "w")

# for (k, v) in rezultat
# 	println(k, " = ", SymbolicUtils.simplify(v))
# end


Cx = Symbolics.Sym{Num}(Symbol("C"))
subst = Dict(Cx => .5/Rx)

a = Dict(rezultat)
Us = SymbolicUtils.simplify(Symbolics.substitute(a[Symbolics.Sym{Num}(Symbol("U3"))], subst))

Ugs = Symbolics.Sym{Num}(Symbol("U"))

Hjw = SymbolicUtils.simplify(Us / Ugs)
println("H(jw) = ", Hjw)

using Latexify
println(latexify(Hjw))
