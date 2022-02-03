include("JuliaCap.jl")
using .JuliaCAP

graf = noviGraf()

#Test1 (radi)
# dodajGranu(graf, Grana(Vg, "V1", [4], [1], [5.]))
# dodajGranu(graf, Grana(R, "R1", [4], [3], [150.]))
# dodajGranu(graf, Grana(R, "R2", [3], [2], [50.]))
# dodajGranu(graf, Grana(R, "R3", [2], [1], [300.]))

# dodajGranu(graf, Grana(Vg, "V1", [4], [1], ["V1"]))
# dodajGranu(graf, Grana(R, "R1", [4], [3], ["R1"]))
# dodajGranu(graf, Grana(R, "R2", [3], [2], ["R2"]))
# dodajGranu(graf, Grana(R, "R3", [2], [1], ["R3"]))

# @Symbolics.variables Ug Rp
# Ug = Symbolics.Sym{Symbolics.Num}(Symbol("Ug"))
# Rp = Symbolics.Sym{Symbolics.Num}(Symbol("Rp"))

# svi ovi testovi rade
# dodajGranu(graf, Grana(Vg, "V1", [3], [1], ["Ug"]))
# dodajGranu(graf, Grana(R, "R1", [2], [1], ["R1"]))
# dodajGranu(graf, Grana(R, "R2", [3], [2], ["R2"]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["Ug"]))
# dodajGranu(graf, Grana(R, "R1", [2], [1], ["R"]))
# dodajGranu(graf, Grana(R, "R2", [2], [1], ["R"]))
# dodajGranu(graf, Grana(R, "R3", [2], [1], ["R"]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [3]))
# dodajGranu(graf, Grana(R, "R1", [2], [1], [100]))
# dodajGranu(graf, Grana(R, "R2", [2], [1], [100]))
# dodajGranu(graf, Grana(R, "R3", [2], [1], [100]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [2]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], [50]))
# dodajGranu(graf, Grana(R, "R2", [3], [1], [50]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["Ug"]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], ["R"]))
# dodajGranu(graf, Grana(R, "R2", [3], [1], ["R"]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [3], ["Ug"]))
# dodajGranu(graf, Grana(R, "R1", [2], [1], ["R1"]))
# dodajGranu(graf, Grana(R, "R2", [3], [1], ["R2"]))


#Test2 (radi)


# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [5.])) #5
# dodajGranu(graf, Grana(R, "R1", [2], [3], [514.]))#514
# dodajGranu(graf, Grana(R, "R2", [3], [4], [123.]))#123
# dodajGranu(graf, Grana(R, "R3", [4], [5], [300.]))#300
# dodajGranu(graf, Grana(R, "R4", [5], [1], [154.]))#154


# radi
dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"])) #5
dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))#514
dodajGranu(graf, Grana(R, "R2", [3], [4], ["R2"]))#123
dodajGranu(graf, Grana(R, "R3", [4], [5], ["R3"]))#300
dodajGranu(graf, Grana(R, "R4", [5], [1], ["R4"]))#154

#Test3 (ne radi kad dodas simplify, ni kad se dodaju dva simplify-a)
# ali radi bez simplify-a
# dodajGranu(graf, Grana(Vg, "V1", [5], [1], ["V1"]))#5
# dodajGranu(graf, Grana(R, "R1", [5], [2], ["R1"]))#150
# dodajGranu(graf, Grana(R, "R3", [2], [1], ["R3"]))#50
# dodajGranu(graf, Grana(R, "R4", [2], [3], ["R4"]))#200
# dodajGranu(graf, Grana(R, "R5", [4], [3], ["R5"]))#50
# dodajGranu(graf, Grana(R, "R6", [3], [1], ["R6"]))#100
# dodajGranu(graf, Grana(VCCS, "VCCS1", [2, 1], [4, 1], ["g"]))#1

# dodajGranu(graf, Grana(Vg, "V1", [5], [1], [5.]))#5
# dodajGranu(graf, Grana(R, "R1", [5], [2], [150.]))#150
# dodajGranu(graf, Grana(R, "R3", [2], [1], [50.]))#50
# dodajGranu(graf, Grana(R, "R4", [2], [3], [200.]))#200
# dodajGranu(graf, Grana(R, "R5", [4], [3], [50.]))#50
# dodajGranu(graf, Grana(R, "R6", [3], [1], [100.]))#100
# dodajGranu(graf, Grana(VCCS, "VCCS1", [2, 1], [4, 1], [1.]))#1

#Test4 (radi)
# dodajGranu(graf, Grana(Vg, "V1", [6], [1], [2.5]))#2.5
# dodajGranu(graf, Grana(Vg, "V2", [2], [1], [2]))#2
# dodajGranu(graf, Grana(R, "R5", [1], [4], [10000]))#10000
# dodajGranu(graf, Grana(R, "R6", [2], [3], [10000]))#10000
# dodajGranu(graf, Grana(R, "R7", [3], [6], [2780]))#2780
# dodajGranu(graf, Grana(R, "R8", [4], [5], [2780]))#2780
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

# dodajGranu(graf, Grana(Vg, "V1", [6], [1], ["V1"]))#2.5
# dodajGranu(graf, Grana(Vg, "V2", [2], [1], ["V2"]))#2
# dodajGranu(graf, Grana(R, "R5", [1], [4], ["R5"]))#10000
# dodajGranu(graf, Grana(R, "R6", [2], [3], ["R6"]))#10000
# dodajGranu(graf, Grana(R, "R7", [3], [6], ["R7"]))#2780
# dodajGranu(graf, Grana(R, "R8", [4], [5], ["R8"]))#2780
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

#Test6
# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [3.]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], [50.]))
# dodajGranu(graf, Grana(R, "R2", [3], [4], [100.]))
# dodajGranu(graf, Grana(C, "C1", [4], [1], [5.], [2.]))

#Isto test6 samo sto su parametri nekih elemenata zamenjeni opstim simbolima
# ne radi kad ima simplify koji je unutar solvera
# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))
# dodajGranu(graf, Grana(R, "R2", [3], [4], ["R2"]))
# dodajGranu(graf, Grana(C, "C1", [4], [1], ["C"], ["U0"]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [3.]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], [50.]))
# dodajGranu(graf, Grana(C, "C1", [3], [1], [5.], [2.]))
# dodajGranu(graf, Grana(L, "L1", [4], [1], [5.], [2.]))

# radi sa dva simplify-a
# dodajGranu(graf, Grana(Vg, "V1", [5], [1], [3.]))
# dodajGranu(graf, Grana(R, "R1", [5], [2], [50.]))
# dodajGranu(graf, Grana(C, "C1", [3], [1], [5.], [2.]))
# dodajGranu(graf, Grana(C, "C2", [4], [1], [5.], [2.]))
# dodajGranu(graf, Grana(VCCS,  "VCCS1", [2, 1], [3, 1], [1]))#a
# dodajGranu(graf, Grana(VCCS,  "VCCS2", [3, 1], [3, 1], [1]))#a
# dodajGranu(graf, Grana(VCCS,  "VCCS3", [3, 1], [4, 1], [1]))#a
# dodajGranu(graf, Grana(VCCS,  "VCCS4", [4, 1], [1, 3], [1]))#a

# dodajGranu(graf, Grana(Vg, "V1", [5], [1], ["V1"]))
# dodajGranu(graf, Grana(R, "R1", [5], [2], ["R1"]))
# dodajGranu(graf, Grana(C, "C1", [3], [1], ["C1"], ["U01"]))
# dodajGranu(graf, Grana(C, "C2", [4], [1], ["C2"], ["U02"]))
# dodajGranu(graf, Grana(VCCS,  "VCCS1", [2, 1], [3, 1], ["a"]))#a
# dodajGranu(graf, Grana(VCCS,  "VCCS2", [3, 1], [3, 1], ["a"]))#a
# dodajGranu(graf, Grana(VCCS,  "VCCS3", [3, 1], [4, 1], ["a"]))#a
# dodajGranu(graf, Grana(VCCS,  "VCCS4", [4, 1], [1, 3], ["a"]))#a

# ne radi sa dva simplify-a, ali radi bez simplify
# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [3.]))
# dodajGranu(graf, Grana(R, "R1", [5], [1], [50.]))
# dodajGranu(graf, Grana(R, "R3", [6], [3], [50.]))
# dodajGranu(graf, Grana(R, "R4", [3], [4], [50.]))
# dodajGranu(graf, Grana(R, "R5", [2], [4], [50.]))
# dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 5], [6]))
# dodajGranu(graf, Grana(opAmp, "opAmp2", [2, 3], [4]))
# dodajGranu(graf, Grana(C, "C2", [5], [6], [5.], [2.]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))
# dodajGranu(graf, Grana(R, "R1", [5], [1], ["R1"]))
# dodajGranu(graf, Grana(R, "R3", [6], [3], ["R3"]))
# dodajGranu(graf, Grana(R, "R4", [3], [4], ["R4"]))
# dodajGranu(graf, Grana(R, "R5", [2], [4], ["R5"]))
# dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 5], [6]))
# dodajGranu(graf, Grana(opAmp, "opAmp2", [2, 3], [4]))
# dodajGranu(graf, Grana(C, "C2", [5], [6], ["C2"], ["U02"]))

#Test7 (radi sa dva simplify-a)

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [3.]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], [50.]))
# dodajGranu(graf, Grana(R, "R2", [3], [4], [100.]))
# dodajGranu(graf, Grana(L, "L1", [4], [1], [5.], [2.]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))
# dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))
# dodajGranu(graf, Grana(R, "R2", [3], [4], ["R2"]))
# dodajGranu(graf, Grana(L, "L1", [4], [1], ["L1"], ["I01"]))

#Test9 (ne radi sa dva simplify-a)
# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))#5
# dodajGranu(graf, Grana(R, "R1", [4], [5], ["R1"]))#10000
# dodajGranu(graf, Grana(R, "R2", [5], [6], ["R2"]))#10000
# dodajGranu(graf, Grana(R, "R3", [2], [3], ["R3"]))#10000
# dodajGranu(graf, Grana(C, "C1", [3], [4], ["C1"], ["Uo"]))#3
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 1], [6]))
# dodajGranu(graf, Grana(opAmp, "opAmp2", [1, 5], [4]))
# dodajGranu(graf, Grana(R, "R4", [6], [1], ["R4"]))

# Test 10 (radi sa dva simplify-a)
# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))#5
# dodajGranu(graf, Grana(R, "R1", [4], [1], ["R1"]))#10000
# dodajGranu(graf, Grana(R, "R2", [4], [5], ["R2"]))#10000
# dodajGranu(graf, Grana(R, "R3", [5], [1], ["R3"]))#10000
# dodajGranu(graf, Grana(R, "R4", [2], [3], ["R4"]))#10000
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [5]))#5
# dodajGranu(graf, Grana(R, "R1", [4], [1], [10000]))#10000
# dodajGranu(graf, Grana(R, "R2", [4], [5], [10000]))#10000
# dodajGranu(graf, Grana(R, "R3", [5], [1], [10000]))#10000
# dodajGranu(graf, Grana(R, "R4", [2], [3], [10000]))#10000
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

# Test 11 (T - sema) -> radi sa dva simplify-a
# dodajGranu(graf, Grana(Vg, "V1", [2], [1], [5]))#5
# dodajGranu(graf, Grana(R, "R1", [2], [3], [10000]))#10000
# dodajGranu(graf, Grana(R, "R2", [3], [6], [10000]))#10000
# dodajGranu(graf, Grana(R, "R3", [6], [1], [10000]))#10000
# dodajGranu(graf, Grana(R, "R4", [6], [5], [10000]))#10000
# dodajGranu(graf, Grana(R, "R5", [4], [1], [10000]))#10000
# dodajGranu(graf, Grana(R, "R6", [5], [1], [10000]))#10000
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

# dodajGranu(graf, Grana(Vg, "V1", [2], [1], ["V1"]))#5
# dodajGranu(graf, Grana(R, "R1", [2], [3], ["R1"]))#10000
# dodajGranu(graf, Grana(R, "R2", [3], [6], ["R2"]))#10000
# dodajGranu(graf, Grana(R, "R3", [6], [1], ["R3"]))#10000
# dodajGranu(graf, Grana(R, "R4", [6], [5], ["R4"]))#10000
# dodajGranu(graf, Grana(R, "R5", [4], [1], ["R5"]))#10000
# dodajGranu(graf, Grana(R, "R6", [5], [1], ["R6"]))#10000
# dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

# Test 12 (radi bez substitute, ali sa njim ne radi), u Linuxu ne radi, ne radi na win 7
# dodajGranu(graf, Grana(Ig, "Ig1", [1], [2], ["Ig1"]))#5
# dodajGranu(graf, Grana(Ig, "Ig2", [4], [3], ["Ig2"]))#5
# dodajGranu(graf, Grana(R, "R1", [5], [6], ["R1"]))#10000
# dodajGranu(graf, Grana(R, "R2", [4], [1], ["R2"]))#10000
# dodajGranu(graf, Grana(R, "R3", [2], [5], ["R3"]))#10000
# dodajGranu(graf, Grana(R, "R4", [6], [3], ["R4"]))#10000
# dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 6], [3]))
# dodajGranu(graf, Grana(opAmp, "opAmp2", [4, 6], [5]))

# Isto test 12 radi bez substitute, ali sa njim ne radi
# dodajGranu(graf, Grana(Ig, "Ig1", [1], [2], [5.]))#5
# dodajGranu(graf, Grana(Ig, "Ig2", [4], [3], [5.]))#5
# dodajGranu(graf, Grana(R, "R1", [5], [6], [10000.]))#10000
# dodajGranu(graf, Grana(R, "R2", [4], [1], [10000.]))#10000
# dodajGranu(graf, Grana(R, "R3", [2], [5], [10000.]))#10000
# dodajGranu(graf, Grana(R, "R4", [6], [3], [10000.]))#10000
# dodajGranu(graf, Grana(opAmp, "opAmp1", [2, 6], [3]))
# dodajGranu(graf, Grana(opAmp, "opAmp2", [4, 6], [5]))

# Test 13 (radi bez oba simplify-a, ali sa jednim ili dva ne radi)
# dodajGranu(graf, Grana(Vg, "V1", [4], [1], ["V1"]))#5
# dodajGranu(graf, Grana(R, "R1", [4], [2], ["R1"]))#10000
# dodajGranu(graf, Grana(R, "R2", [2], [3], ["R2"]))#10000
# dodajGranu(graf, Grana(InductiveT, "T1", [2, 1], [3, 1], ["L1", "L2", "L12"], ["I01", "I02"]))

# Test 14 (radi sa jednim i nijednim simplify, a sa dva ne radi)
# dodajGranu(graf, Grana(Vg, "V1", [4], [1], ["V1"]))#5
# dodajGranu(graf, Grana(R, "R1", [4], [2], ["Zc"]))#10000
# dodajGranu(graf, Grana(R, "R2", [3], [1], ["Zc"]))#10000
# dodajGranu(graf, Grana(T, "T1", [2, 1], [3, 1], ["Zc", "tau"]))#10000

# ovo nije test primer
#dodajGranu(graf, Grana(R, "R4", [3], [4], [200.]))
#dodajGranu(graf, Grana(R, "R5", [5], [4], [50.]))
#dodajGranu(graf, Grana(R, "R6", [4], [1], [100.]))
#dodajGranu(graf, Grana(VCVS,  "VCVS", [2, 1], [4, 1], 1))#a
#dodajGranu(graf, Grana(CCVS,  "CCVS", [3, 1], [5, 1], 2.))#r
#dodajGranu(graf, Grana(VCCS,  "VCCS", [3, 1], [5, 1], 1.))#g
#dodajGranu(graf, Grana(CCCS,  "CCCS", [3, 1], [5, 1], [5.]))#a
#dodajGranu(graf, Grana(opAmp, "opAmp1", [3, 4], [5]))

# dumpDot(graf, "test.dot")
#
arg = Dict{String, Any}("w" => "w", "replacement" => "10")
rezultat = resiKolo(graf, arg)
ispisi_rezultate(rezultat)
using Latexify
for (k, v) in rezultat
	println(latexify(k ~ v))
end
#println()
# ispisi_specifican_rezultat(rezultat, "U2")

# TODO
#NAPRAVITI LEP ISPIS JEDNACINA
#ZAOKRUZITI VREDNOSTI I OBRISATI -0
#PROVERITI GRESKE
