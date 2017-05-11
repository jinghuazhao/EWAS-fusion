#!/bin/bash
#11-5-2017 MRC-Epid JHZ

if [ $# -lt 1 ] || [ "$1" == "-h" ]; then
    echo "Usage: ewas-fusion.sh <input>"
    echo "where <input> is in tab-delimited format:"
    echo "SNP A1 A2 Z"
    echo "The output is contained in <$1.tmp>"
    exit
fi
dir=$(pwd)/$(basename $1).tmp
if [ ! -d $dir ]; then
   mkdir -p $dir
fi
# SNP   pos     A1      A2      Z

EWAS_fusion=/genetics/bin/EWAS-fusion
awk '(NR>1) {
  FS=OFS="\t"
  $3=toupper($3)
  $4=toupper($4)
  print $1, $2, $3, $4, $5
}' $dir.txt | \
sort -k1,1 | \
join -12 -21 $EWAS_fusion/EWAS.bim - | \
awk -f $EWAS_fusion/CLEAN_ZSCORES.awk | \
awk '{if(NR==1) print "SNP","A1","A2","Z"; else {$2="";print}}' > $dir.input
ln -sf $EWAS_fusion/glist-hg19 $dir/glist-hg19

WGT=$EWAS_fusion/EWAS/
LDREF=$EWAS_fusion/LDREF
FUSION=/genetics/bin/fusion_twas
RSCRIPT=/genetics/data/software/bin/Rscript
engine=sge
if [[ $engine == "" ]];then
qsub -cwd -sync y \
     -v EWAS_fusion=$EWAS_fusion \
     -v dir=$dir \
     -v sumstats=$(pwd)/$1 \
     -v WGT=$WGT \
     -v LDREF=$LDREF \
     -v FUSION=$FUSION \
     -v RSCRIPT=$RSCRIPT \
     -v LOCUS_WIN=500000 \
     $EWAS_fusion/ewas-fusion.qsub
else
parallel --dry-run '/bin/bash $EWAS_fusion {}{}{}{}{}{}{}{}{}::: $(seq 22) ::: $dir ::: $WGT ::: $LDREF ::: $sumstats ::: $FUSION ::: $RSCRIPT ::: $EWAS_fusion ::: $LOCUS_WIN
fi
