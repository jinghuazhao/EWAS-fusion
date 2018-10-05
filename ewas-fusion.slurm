#SBATCH -o $HOME/EWAS.o
#SBATCH -e $HOME/EWAS.e
#SBATCH -J EWASfusion
#SBATCH -a 1-22

$EWAS_fusion/ewas-fusion.subs $SLURM_ARRAU_TASK_ID $dir $WGT $LDREF $sumstats $FUSION $RSCRIPT $EWAS_fusion $LOCUS_WIN $N
