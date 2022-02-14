include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))
dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))
dodajGranu(graf, Grana(R, "R2", [3], [4], ["R2"]))
dodajGranu(graf, Grana(C, "C1", [4], [1], ["C"], ["U0"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
