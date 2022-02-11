include("JuliaCap.jl")
import .JuliaCAP
#using .JuliaCAP


graf = JuliaCAP.noviGraf()

#Example1 - deluje da radi, oni imaju ovo menjanje w i uproscavanje pa nije bas zgodno proveriti
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [2], [1], ["Vg"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [3], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [4], ["C1"], ["UC0"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [4], [1], ["L1"], ["IL0"]))


#Example2 - deluje dobro, oni imaju replacement pa je vg vstep/s
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [2], [1], ["Vg"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [3], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [1], ["C1"], ["UC0"]))


#Example3 - deluje dobro izgleda da C ne moze da nema pocetne uslove => RESENO
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS1", [2, 1], [3, 1], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS2", [3, 1], [3, 1], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS3", [3, 1], [4, 1], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.VCCS,  "VCCS4", [4, 1], [1, 3], ["a"]))#a
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [3], [1], ["C1"], ["UC0"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C2", [4], [1], ["C2"], ["UC0"]))


#Example4 - deluje da radi, nemoguce protumaciti resenje
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [2], [1], ["V1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [2, 5], [6]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [5], [1], ["R1"]))
# JuliaCAP.dodajGranu(graf,  JuliaCAP.Grana( JuliaCAP.C, "C2", [5], [6], ["C2"], ["U02"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [3], ["R3"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp2", [2, 3], [4]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], ["R3"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R5", [2], [4], ["R3"]))


#Example5 - vodovi, znamo da ne radi
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [5], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [2], [5], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [4], [1], ["R3"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [3], [4], ["R4"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.T, "T1", [2, 1], [3, 1], ["Zc", "tau"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.T, "T2", [2, 1], [4, 1], ["Zc", "tau"]))#10000

#Example6 - transmission line - vodovi, znamo da ne radi
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "V1", [4], [1], ["V1"]))#5
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [2], ["R1"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], ["R2"]))#10000
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.T, "T1", [2, 1], [3, 1], ["Zc", "tau"]))#10000

#Example7 - deluje da je dobro
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [6], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [6], [3], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [4], ["R3"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R0", [6], [5], ["R0"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg1", [2], [1], ["Vg1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg2", [3], [1], ["Vg2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg3", [4], [1], ["Vg3"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [1, 6], [5]))


#Example8 - deluje da je dobro
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [6], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [5], [3], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R3", [6], [4], ["R3"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R4", [1], [5], ["R4"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg1", [2], [1], ["Vg1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg2", [3], [1], ["Vg2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.opAmp, "opAmp1", [5, 6], [4]))


#Example9 - deluje dobro, opet imaju neke zamene pa se ne da lepo proveriti, ovo dalje sa laplasom nzm o cemu se radi
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg1", [4], [1], ["Vg1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [1], [3], ["R2"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.InductiveT, "T1", [2, 1], [3, 1], ["L1", "L2", "L12"], ["I01", "I02"]))


#Example10 - radi, ali fora kod njih je sto za ovo w ne treba da bude resenja, a mi posto nemamo w da se zadaje svakako imamo resenje
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [2], [1], ["Vg"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [1], [3], ["C1"], ["UC0"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [3], [2], ["L1"], ["IL0"]))


#Example11 - singularexception, zbuni se jer nema resenja a nigde ne hendlujemo tu opciju
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg1", [1], [2], ["Vg1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg2", [1], [2], ["Vg2"]))


#Example12 - deluje u redu, nemoguce protumaciti resenje
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [2], [1], ["Vg"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [4], [1], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.InductiveT, "T1", [3, 1], [2, 1], ["L1", "L2", "L12"], ["I01", "I02"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.InductiveT, "T2", [4, 1], [3, 1], ["L3", "L4", "L34"], ["I03", "I04"]))


#Example13 - kad se sredi dobro je resenje
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [2], [1], ["Vg"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R1", [3], [2], ["R1"]))
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.R, "R2", [3], [1], ["R2"]))


#Example14.1 - radi
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [2], [1], ["Vg"]))


#Example14.2 - ne radi, singularexception, kolo nema resenje pa se zbuni
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Vg, "Vg", [1], [1], ["Vg"]))


#Example15.1 - prazni simboli, ne baca exception al ne nema resenje
#JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Ig, "Ig", [1], [1], ["Ig"]))


#Example15.2 - neki exception matrix is not square
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.Ig, "Ig", [2], [1], ["Ig"]))


#Example16.1 - dobro, kod njih je s kod nas jw i ovo bi trebalo da moze da uprosti :)
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [2], [1], ["C1"], ["UC0"]))


#Example16.2 - prazni simboli, ne baca exception al ne nema resenje
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.C, "C1", [1], [1], ["C1"], ["UC0"]))


#Example17.1 - dobro, samo kad bi jos i uprostio banalan izrazzz
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [2], [1], ["L1"], ["IL0"]))


#Example17.2 - prazni simboli, ne baca exception al ne nema resenje
# JuliaCAP.dodajGranu(graf, JuliaCAP.Grana(JuliaCAP.L, "L1", [1], [1], ["L1"], ["IL0"]))

arg = Dict{String, Any}("w" => "", "replacement" => "10")
rezultat = JuliaCAP.resiKolo(graf, arg)
JuliaCAP.ispisi_jednacine()
JuliaCAP.ispisi_jednacine_latex()
#JuliaCAP.ispisi_rezultate(rezultat)
#JuliaCAP.ispisi_specifikacije_kola(graf)
#JuliaCAP.ispisi_rezultate_latex(rezultat)
#println()
#JuliaCAP.ispisi_specifican_rezultat(rezultat, "IT13")
#JuliaCAP.ispisi_specifican_rezultat_latex(rezultat, "U4")   