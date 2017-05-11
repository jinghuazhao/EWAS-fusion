#!/bin/bash
# 11-5-2017 MRC-Epid JHZ

awk '{
  FS=OFS="\t";
  t=NR
  if(NR==1) print "SNP","A1","A2","Z"
  else print $1,$2,$3,$5/$6
}' /genetics/data/twas/14-10-16/GIANT/GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt \
   | sort -k1,1 > height

ewas-fusion.sh height
rm height
