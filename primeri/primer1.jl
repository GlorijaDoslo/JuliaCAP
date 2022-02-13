include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 1
dodajGranu(graf, Grana(Vg, "U", [2], [1], ["U"]))
dodajGranu(graf, Grana(R, "R1", [2], [4], ["R1"]))
dodajGranu(graf, Grana(R, "R2", [5], [3], ["R2"]))
dodajGranu(graf, Grana(R, "R3", [6], [1], ["R3"]))
dodajGranu(graf, Grana(C, "C1", [5], [4], ["C1"]))
dodajGranu(graf, Grana(C, "C2", [5], [3], ["C2"]))
dodajGranu(graf, Grana(opAmp, "opAmp1", [5, 6], [3]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)
