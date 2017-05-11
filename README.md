# EWAS-fusion
Epigenome-wide association study FUSION

The repository contains information on FUSION analysis using epigenome data. 

## Requirements

To begin, the software [FUSION](http://gusevlab.org/projects/fusion/) is required. Other facilities to be required are

1. Sun grid engine (sge) similar to those at MRC Epidemiology Unit Linux clusters.

2, Weight files based on epigenetic data.

## Input

The input file contains GWAS summary statistics similar to [.sumstats](https://github.com/bulik/ldsc/wiki/Summary-Statistics-File-Format) as in [LDSC](https://github.com/bulik/ldsc) with the following columns.

   * SNP -- RS id of SNPs
   * A1  -- Effect allele (first allele)
   * A2  -- Other allele (second allele)
   * Z   -- Z-scores, taking sign with repect to A1

## Use of the programs
```
ewas-sge.sh input-file
```
These will send jobs to the Linux clusters.

## Conditional analysis

Example code is as follows,
```
# 11-5-2017 MRC-Epid JHZ
# to extract the transcriptome-wide significant associations 0.05/79569 probes
# and conduct conditional analysis

fusion_dir=/genetics/bin/EWAS-fusion
work_dir=/genetics/data/twas/9-5-17

for trait in IA_DIAGRAM_UKBB_GWAS
do
  for chr in `seq 22`
  do
  cd $work_dir/1M/sge
  awk -f $work_dir/post_process.awk $work_dir/$trait-$chr.dat > $work_dir/1M/$trait-$chr.top
  sge "/genetics/bin/fusion_twas/FUSION.post_process.R \
   --sumstats $work_dir/$trait.txt \
   --input $work_dir/1M/$trait-$chr.top \
   --out $work_dir/1M/$trait-$chr \
   --ref_ld_chr $fusion_dir/LDREF2/EWAS \
   --chr $chr --plot --locus_win 500000"
  done
done
```
