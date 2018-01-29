# 29-1-2018 MRC-Epid JHZ

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

seq 22 | awk -vo=$o '{print o "/chr" $1}' > merge-list
plink-1.9 --merge-list merge-list --make-bed --out $o/EPIC

export a=$o/EPIC
export b=/genetics/bin/FUSION/LDREF/EUR
export w=/genetics/data/twas/25-1-18

sort -k2,2 $b.bim > LDREF.bim
sort -k2,2 $a.bim | join -j2 - LDREF.bim | cut -d' ' -f1 > LDREF.snps
rm LDREF.bim

plink-1.9 --bfile $a --extract LDREF.snps --make-bed --threads 12 --out EPIC

## extract CpG SNPs via PLINK

export f=500000
export o=/scratch/tempjhz22/FUSION/1KG
cat CpG.txt | parallel -j10 --env w --env f --env o -C' ' '
   export l=$(({4}-$f)); \
   if [ $l -lt 1 ]; then export l=0; fi; \
   export u=$(({4}+$f)); \
   mkdir $o/{1}; \
   /genetics/bin/plink-1.9 --bfile $w/EPIC --make-bed --maf 0.01 \
                 --chr {3} --from-bp $l --to-bp $u --out $o/{1}/{1}'

