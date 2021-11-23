#!/bin/bash

#SBATCH --account CARDIO-SL0-CPU
#SBATCH --ntasks=1
#SBATCH --job-name=EWASfusion
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=cardio
#SBATCH --qos=cardio
#SBATCH --array=1-22
#SBATCH --output=EWAS_%A_%a.out
#SBATCH --error=EWAS_%A_%a.err
#SBATCH --export ALL

function load_cardio_modules()
{
. /etc/profile.d/modules.sh
  module load default-cardio
  module load slurm
  module load use.own
}

export TMPDIR=$rt/tmp
$EWAS_fusion/ewas-fusion.subs $SLURM_ARRAY_TASK_ID $dir $WGT $LDREF $sumstats $FUSION $RSCRIPT $EWAS_fusion $LOCUS_WIN $N
