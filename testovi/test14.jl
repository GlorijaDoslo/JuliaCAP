include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [4], [1], ["V1"]))#5
dodajGranu(graf, Grana(R, "R1", [4], [2], ["Zc"]))#10000
dodajGranu(graf, Grana(R, "R2", [3], [1], ["Zc"]))#10000
dodajGranu(graf, Grana(T, "T1", [2, 1], [3, 1], ["Zc", "tau"]))#10000

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
