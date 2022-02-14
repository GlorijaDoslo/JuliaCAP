include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

# PRIMER 7
dodajGranu(graf, Grana(Vg,    "U",    [4],    [5],    ["U"]))
dodajGranu(graf, Grana(R,     "R1",   [2],    [1],    ["R1"]))
dodajGranu(graf, Grana(C,     "C1",   [1],    [2],    ["C1"]))
dodajGranu(graf, Grana(R,     "R2",   [2],    [3],    ["R2"]))
dodajGranu(graf, Grana(C,     "C2",   [3],    [4],    ["C2"]))
dodajGranu(graf, Grana(VCVS,  "VCVS", [2, 1], [5, 1], ["a"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)
