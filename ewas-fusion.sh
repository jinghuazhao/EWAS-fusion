#!/bin/bash
#6-3-2019 MRC-Epid JHZ

engine=slurm

if [ $# -lt 1 ] || [ "$1" == "-h" ]; then
    echo "Usage: ewas-fusion.sh <input>"
    echo "where <input> has the following columns:"
    echo "SNP A1 A2 Z"
    echo "The output is contained in <$1.tmp>"
    exit
fi
if [ $(dirname $1) == "." ]; then
   dir=$(pwd)/$(basename $1).tmp
else
   dir=$1.tmp
fi
if [ ! -d $dir ]; then
   mkdir -p $dir
fi
export THREADS=10
export EWAS_fusion=/scratch/jhz22/EWAS-fusion
awk '(NR>1) {
  OFS="\t"
  $2=toupper($2)
  $3=toupper($3)
  print $1, NR, $2, $3, $4
}' $1 | \
sort -k1,1 | \
join -12 -21 $EWAS_fusion/EUR.bim - | \
awk -f $EWAS_fusion/CLEAN_ZSCORES.awk | \
awk '{if(NR==1) print "SNP","A1","A2","Z"; else {$2="";print}}' > $dir/$(basename $1).input
ln -sf $EWAS_fusion/glist-hg19 $dir/glist-hg19
export dir=$dir
export WGT=$EWAS_fusion/EWAS-weights/
export LDREF=$EWAS_fusion/LDREF/1000G.EUR.
export sumstats=$dir/$(basename $1).input
export FUSION=/genetics/bin/fusion_twas
export RSCRIPT=/usr/local/bin/Rscript
export LOCUS_WIN=500000
export N=$(/bin/awk 'END{print FNR-1}' $EWAS_fusion/EWAS-weights.pos)
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
elif [ $engine == "slurm" ]; then
     sbatch --wait --export ALL $EWAS_fusion/ewas-fusion.slurm
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
         --env N \
         -C' ' '/bin/bash $EWAS_fusion/ewas-fusion.subs {} $dir $WGT $LDREF $sumstats $FUSION $RSCRIPT $EWAS_fusion $LOCUS_WIN $N' ::: $(seq 22)
fi
