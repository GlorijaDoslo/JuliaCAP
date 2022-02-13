include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [5], [1], [3.]))
dodajGranu(graf, Grana(R, "R1", [5], [2], [50.]))
dodajGranu(graf, Grana(C, "C1", [3], [1], [5.], [2.]))
dodajGranu(graf, Grana(C, "C2", [4], [1], [5.], [2.]))
dodajGranu(graf, Grana(VCCS,  "VCCS1", [2, 1], [3, 1], [1]))#a
dodajGranu(graf, Grana(VCCS,  "VCCS2", [3, 1], [3, 1], [1]))#a
dodajGranu(graf, Grana(VCCS,  "VCCS3", [3, 1], [4, 1], [1]))#a
dodajGranu(graf, Grana(VCCS,  "VCCS4", [4, 1], [1, 3], [1]))#a

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
