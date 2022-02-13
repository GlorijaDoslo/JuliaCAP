include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))
dodajGranu(graf, Grana(R, "R1", [5], [1], ["R1"]))
dodajGranu(graf, Grana(R, "R3", [6], [3], ["R3"]))
dodajGranu(graf, Grana(R, "R4", [3], [4], ["R4"]))
dodajGranu(graf, Grana(R, "R5", [2], [4], ["R5"]))
dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 5], [6]))
dodajGranu(graf, Grana(opAmp, "opAmp2", [2, 3], [4]))
dodajGranu(graf, Grana(C, "C2", [5], [6], ["C2"], ["U02"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
