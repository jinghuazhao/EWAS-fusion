# 28-1-2018 MRC-Epid JHZ

export i=/gen_omics/data/EPIC-Norfolk/imputedfiles_parts/
export b=/genetics/bin/FUSION/LDREF/1000G.EUR
export o=/scratch/tempjhz22/LDcalc/Omics
export w=/genetics/data/twas/25-1-18

cut -f2 data/Archive/Inds.txt > Inds.dat
seq 22 | parallel -j1 --env i --env b --env o -C' ' '
   cut -f2 $b.{}.bim > $o/LDREF{}.snps; \
   qctool_v2.0 -filetype bgen -g $i/chr{}.bgen -s $i/EPICNorfolk.sample \
               -ofiletype binary_ped -og $o/chr{} -incl-samples Inds.dat \
               -incl-rsids $o/LDREF{}.snps -threads 5'
