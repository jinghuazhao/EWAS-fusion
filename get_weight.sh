#!/bin/bash
# 28-1-2018 MRC-Epid JHZ

export CpG=/genetics/data/twas/25-1-18/CpG.txt
export b=/genetics/bin
export d=/genetics/data/twas/25-1-18
export o=/scratch/tempjhz22/FUSION
export f=/genetics/bin/FUSION.compute_weights.R
export p=/genetics/bin/plink-1.9

function get_weight_in_parallel ()
{
   parallel -j1 --env b --env o --env d --env f --env p -C' ' '
   echo {1} {2} {3} {4}; \
   cd $o; \
   if [ {2} -eq 1 ]; then ops="--remove $d/{1}"; fi; \
   export ops=""; \
   $p --make-bed --missing-phenotype -999 --pheno $d.pheno --covar $d.covar --bfile $o/plink/{1} --maf 0.01 --pheno-name {1} $ops --out {1}; \
   $f --bfile={1} --tmp={1}_t --covar={1}.cov --PATH_gcta=$b/gcta_nr_robust --PATH_plink=$p --PATH_gemma=$b/gemma_1_thread \
      --crossval=5 --models=top1,lasso,enet --save_hsq --out=weights/{1}; \
   /bin/rm -f {1}.*'
}

export chunk=$1
export chr=$2

if [ ! -z "$chr" ]
then
   export sl=$(($(awk '$3==chr' chr=$chr $CpG | wc -l)/60+1))
   awk '$3==chr' chr=$chr $CpG | awk 'NR==(v-1)*sl+1, NR==v*sl' v=$chunk sl=$sl | get_weight_in_parallel
else
   export sl=$(($(wc -l $CpG | cut -d' ' -f1)/60+1))
   awk 'NR==(v-1)*sl+1, NR==v*sl' v=$chunk sl=$sl $CpG | get_weight_in_parallel
fi
