include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

using Symbolics
using SymbolicUtils

Rx = Symbolics.Sym{Num}(Symbol("R"))

# PRIMER 11 FILTER
dodajGranu(graf, Grana(Vg,    "U",      [2],    [1], ["U"]))
dodajGranu(graf, Grana(R,     "R4",     [2],    [6], [.75 * Rx]))
dodajGranu(graf, Grana(R,     "R1",     [6],    [3], [1.5 * Rx]))
dodajGranu(graf, Grana(C,     "C1",     [6],    [3], ["C"]))
dodajGranu(graf, Grana(opAmp, "opAmp1", [1, 6], [3]))
dodajGranu(graf, Grana(R,     "R7",     [7],    [3], [Rx]))
dodajGranu(graf, Grana(R,     "R8",     [7],    [4], [Rx]))
dodajGranu(graf, Grana(opAmp, "opAmp2", [1, 7], [4]))
dodajGranu(graf, Grana(R,     "R2",     [8],    [4], [Rx]))
dodajGranu(graf, Grana(C,     "C2",     [8],    [5], ["C"]))
dodajGranu(graf, Grana(opAmp, "opAmp3", [1, 8], [5]))
dodajGranu(graf, Grana(R,     "R3",     [6],    [5], [Rx]))
dodajGranu(graf, Grana(R,     "R9",     [5],    [1], ["R9"]))


rezultat = resiKolo(graf, omega = "w")

for (k, v) in rezultat
	println(k, " = ", SymbolicUtils.simplify(v))
end


Cx = Symbolics.Sym{Num}(Symbol("C"))
subst = Dict(Cx => 1/Rx)

a = Dict(rezultat)
Us = SymbolicUtils.simplify(Symbolics.substitute(a[Symbolics.Sym{Num}(Symbol("U3"))], subst))

Ugs = Symbolics.Sym{Num}(Symbol("U"))

Hjw = SymbolicUtils.simplify(Us / Ugs)
println("H(jw) = ", Hjw)

using Latexify
println(latexify(Hjw))
