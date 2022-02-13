include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [4], [1], ["V1"]))
dodajGranu(graf, Grana(R, "R1", [4], [3], ["R1"]))
dodajGranu(graf, Grana(R, "R2", [3], [2], ["R2"]))
dodajGranu(graf, Grana(R, "R3", [2], [1], ["R3"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)
