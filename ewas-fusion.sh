#!/bin/bash
#11-5-2017 MRC-Epid JHZ

#parallel '/bin/echo {1} {2} /genetics/bin/FUSION/GTEx/{1}' ::: $(/bin/cat ../GTEx.list) ::: $(seq 22)>../GTEx.runlist

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
EWAS_fusion=/genetics/bin/EWAS-fusion
ln -sf $WAS_fusion/glist-hg19 $dir/glist-hg19
WGT=$EWAS_fusion/EWAS/
LDREF=$EWAS_fusion/LDREF
qsub -cwd -sync y -v EWAS_fusion=$EWAS_fusion -v dir=$dir -v sumstats=$(pwd)/$1 -v WGT=$WGT -v LDREF=$LDREF $EWAS_fusion/ewas-fusion.qsub
