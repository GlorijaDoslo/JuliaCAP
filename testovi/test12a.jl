include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Ig, "Ig1", [1], [2], ["Ig1"]))#5
dodajGranu(graf, Grana(Ig, "Ig2", [4], [3], ["Ig2"]))#5
dodajGranu(graf, Grana(R, "R1", [5], [6], ["R1"]))#10000
dodajGranu(graf, Grana(R, "R2", [4], [1], ["R2"]))#10000
dodajGranu(graf, Grana(R, "R3", [2], [5], ["R3"]))#10000
dodajGranu(graf, Grana(R, "R4", [6], [3], ["R4"]))#10000
dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 6], [3]))
dodajGranu(graf, Grana(opAmp, "opAmp2", [4, 6], [5]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
