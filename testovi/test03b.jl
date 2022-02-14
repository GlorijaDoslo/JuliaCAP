include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [5], [1], [5.]))#5
dodajGranu(graf, Grana(R, "R1", [5], [2], [150.]))#150
dodajGranu(graf, Grana(R, "R3", [2], [1], [50.]))#50
dodajGranu(graf, Grana(R, "R4", [2], [3], [200.]))#200
dodajGranu(graf, Grana(R, "R5", [4], [3], [50.]))#50
dodajGranu(graf, Grana(R, "R6", [3], [1], [100.]))#100
dodajGranu(graf, Grana(VCCS, "VCCS1", [2, 1], [4, 1], [1.]))#1

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
