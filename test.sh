#!/bin/bash
# 29-3-2019 JHZ
# 24-5-2017 MRC-Epid JHZ

wget http://portals.broadinstitute.org/collaboration/giant/images/0/01/GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz
gunzip -c GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz | \
awk '{
  FS=OFS="\t";
  t=NR
  if(NR==1) print "SNP","A1","A2","Z"
  else print $1,$2,$3,$5/$6
}' | sort -k1,1 > height

ewas-fusion.sh height
Rscript ewas-annotate.R height.tmp
Rscript ewas-plot.R height.tmp

rm GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz height
