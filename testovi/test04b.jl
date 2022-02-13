include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [6], [1], ["V1"]))#2.5
dodajGranu(graf, Grana(Vg, "V2", [2], [1], ["V2"]))#2
dodajGranu(graf, Grana(R, "R5", [1], [4], ["R5"]))#10000
dodajGranu(graf, Grana(R, "R6", [2], [3], ["R6"]))#10000
dodajGranu(graf, Grana(R, "R7", [3], [6], ["R7"]))#2780
dodajGranu(graf, Grana(R, "R8", [4], [5], ["R8"]))#2780
dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
