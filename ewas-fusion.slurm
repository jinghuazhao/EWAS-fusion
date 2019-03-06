#!/bin/bash

#SBATCH -o $HOME/EWAS.o
#SBATCH -e $HOME/EWAS.e
#SBATCH -J EWASfusion
#SBATCH -t 0-6:0
#SBATCH -a 1-22

export TMPDIR=$rt/tmp
$EWAS_fusion/ewas-fusion.subs $SLURM_ARRAU_TASK_ID $dir $WGT $LDREF $sumstats $FUSION $RSCRIPT $EWAS_fusion $LOCUS_WIN $N
