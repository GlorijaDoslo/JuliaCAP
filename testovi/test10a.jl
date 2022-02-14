include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))#5
dodajGranu(graf, Grana(R, "R1", [4], [1], ["R1"]))#10000
dodajGranu(graf, Grana(R, "R2", [4], [5], ["R2"]))#10000
dodajGranu(graf, Grana(R, "R3", [5], [1], ["R3"]))#10000
dodajGranu(graf, Grana(R, "R4", [2], [3], ["R4"]))#10000
dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
