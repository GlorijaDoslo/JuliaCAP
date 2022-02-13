include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [2], [1], [3.]))
dodajGranu(graf, Grana(R, "R1", [2], [3], [50.]))
dodajGranu(graf, Grana(R, "R2", [3], [4], [100.]))
dodajGranu(graf, Grana(C, "C1", [4], [1], [5.], [2.]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
