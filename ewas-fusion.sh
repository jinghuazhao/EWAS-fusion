#!/bin/bash
#12-5-2017 MRC-Epid JHZ

engine=sge

# SNP	A1	A2	Z
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
export THREADS=10
export EWAS_fusion=/genetics/bin/EWAS-fusion
awk '(NR>1) {
  FS=OFS="\t"
  $2=toupper($2)
  $3=toupper($3)
  print $1, NR, $2, $3, $4
}' $1 | \
sort -k1,1 | \
join -12 -21 $EWAS_fusion/EWAS.bim - | \
awk -f $EWAS_fusion/CLEAN_ZSCORES.awk | \
awk '{if(NR==1) print "SNP","A1","A2","Z"; else {$2="";print}}' > $dir/$1.input
ln -sf $EWAS_fusion/glist-hg19 $dir/glist-hg19
export dir=$dir
export WGT=$EWAS_fusion/EWAS/
export LDREF=$EWAS_fusion/LDREF/EWAS
export sumstats=$dir/$1.input
export FUSION=/genetics/bin/fusion_twas
export RSCRIPT=/usr/local/bin/Rscript
export LOCUS_WIN=500000
N=$(/bin/awk 'END{print FNR-1}' $EWAS_fusion/RDat.pos)
if [[ $engine == "sge" ]];then
qsub -cwd -sync y \
     -v EWAS_fusion=$EWAS_fusion \
     -v dir=$dir \
     -v sumstats=$sumstats \
     -v WGT=$WGT \
     -v LDREF=$LDREF \
     -v FUSION=$FUSION \
     -v RSCRIPT=$RSCRIPT \
     -v LOCUS_WIN=$LOCUS_WIN \
     -v N=$N \
     $EWAS_fusion/ewas-fusion.qsub
else
parallel -j$THREADS \
         --env EWAS_fusion \
         --env dir \
         --env WGT \
         --env LDREF \
         --env sumstats \
         --env FUSION \
         --env RSCRIPT \
         --env LOCUS_WIN \
         --env N=$N \
         -C' ' '/bin/bash $EWAS_fusion/ewas-fusion.subs {} $dir $WGT $LDREF $sumstats $FUSION $RSCRIPT $EWAS_fusion $LOCUS_WIN $N' ::: $(seq 22)
fi
