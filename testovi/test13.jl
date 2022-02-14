include("../JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

dodajGranu(graf, Grana(Vg, "V1", [4], [1], ["V1"]))#5
dodajGranu(graf, Grana(R, "R1", [4], [2], ["R1"]))#10000
dodajGranu(graf, Grana(R, "R2", [2], [3], ["R2"]))#10000
dodajGranu(graf, Grana(InductiveT, "T1", [2, 1], [3, 1], ["L1", "L2", "L12"], ["I01", "I02"]))

rezultat = resiKolo(graf; omega = "w")

ispisi_rezultate(rezultat)

using SymbolicUtils
for (k, v) in rezultat
end
