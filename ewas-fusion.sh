#!/bin/bash
#11-5-2017 MRC-Epid JHZ

if [ $# -lt 1 ] || [ "$1" == "-h" ]; then
    echo "Usage: gtex-sge.sh <input>"
    echo "where <input> is in tab-delimited format:"
    echo "SNP A1 A2 Z N"
    echo "The output is contained in <$1.tmp>"
    exit
fi
dir=$(pwd)/$(basename $1).tmp
if [ ! -d $dir ]; then
   mkdir -p $dir
fi
# SNP   pos     A1      A2      Effect  se      N

EWAS_fusion=/genetics/bin/EWAS-fusion
awk '(NR>1) {
  FS=OFS="\t"
  $3=toupper($3)
  $4=toupper($4)
  print $1, $2, $3, $4, $5/$6, $7
}' $dir.txt | \
sort -k1,1 | \
join -12 -21 $EWAS_fusion/EWAS.bim - | \
awk -f $EWAS_fusion/CLEAN_ZSCORES_N.awk | \
awk '{if(NR==1) print "SNP","A1","A2","Z","N"; else {$2="";print}}' > $dir.input

WGT=$EWAS_fusion/EWAS/
LDREF=$EWAS_fusion/LDREF
ln -sf $EWAS_fusion/glist-hg19 $dir/glist-hg19
FUSION=/genetics/bin/fusion_twas
RSCRIPT=/genetics/data/software/bin/Rscript
qsub -cwd -sync y \
     -v EWAS_fusion=$EWAS_fusion -v dir=$dir -v sumstats=$(pwd)/$1 -v WGT=$WGT -v LDREF=$LDREF -v FUSION=$FUSION -v RSCRIPT=$RSCRIPT -vLOCUS_WIN=500000 \
     $EWAS_fusion/ewas-fusion.qsub

#parallel '/bin/echo {1} {2} /genetics/bin/FUSION/GTEx/{1}' ::: $(/bin/cat ../GTEx.list) ::: $(seq 22)>../GTEx.runlist
