include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [2], [1], [5.])) #5
dodajGranu(graf, Grana(R, "R1", [2], [3], [514.]))#514
dodajGranu(graf, Grana(R, "R2", [3], [4], [123.]))#123
dodajGranu(graf, Grana(R, "R3", [4], [5], [300.]))#300
dodajGranu(graf, Grana(R, "R4", [5], [1], [154.]))#154

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
