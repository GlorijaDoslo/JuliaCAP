include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 2
dodajGranu(graf, Grana(Vg, "U", [2], [1], ["U"]))
dodajGranu(graf, Grana(R, "R1", [1], [5], ["R1"]))
dodajGranu(graf, Grana(C, "C2", [5], [6], ["C2"]))
dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 5], [6]))
dodajGranu(graf, Grana(opAmp, "opAmp2", [2, 3], [4]))
dodajGranu(graf, Grana(R, "R3", [6], [3], ["R3"]))
dodajGranu(graf, Grana(R, "R4", [3], [4], ["R4"]))
dodajGranu(graf, Grana(R, "R5", [2], [4], ["R5"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)
