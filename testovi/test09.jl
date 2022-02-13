include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))#5
dodajGranu(graf, Grana(R, "R1", [4], [5], ["R1"]))#10000
dodajGranu(graf, Grana(R, "R2", [5], [6], ["R2"]))#10000
dodajGranu(graf, Grana(R, "R3", [2], [3], ["R3"]))#10000
dodajGranu(graf, Grana(C, "C1", [3], [4], ["C1"], ["Uo"]))#3
dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 1], [6]))
dodajGranu(graf, Grana(opAmp, "opAmp2", [1, 5], [4]))
dodajGranu(graf, Grana(R, "R4", [6], [1], ["R4"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
