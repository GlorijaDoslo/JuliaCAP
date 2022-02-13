include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [5], [1], ["V1"]))
dodajGranu(graf, Grana(R, "R1", [5], [2], ["R1"]))
dodajGranu(graf, Grana(C, "C1", [3], [1], ["C1"], ["U01"]))
dodajGranu(graf, Grana(C, "C2", [4], [1], ["C2"], ["U02"]))
dodajGranu(graf, Grana(VCCS,  "VCCS1", [2, 1], [3, 1], ["a"]))#a
dodajGranu(graf, Grana(VCCS,  "VCCS2", [3, 1], [3, 1], ["a"]))#a
dodajGranu(graf, Grana(VCCS,  "VCCS3", [3, 1], [4, 1], ["a"]))#a
dodajGranu(graf, Grana(VCCS,  "VCCS4", [4, 1], [1, 3], ["a"]))#a

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
