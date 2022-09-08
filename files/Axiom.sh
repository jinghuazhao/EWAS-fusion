# 29-1-2018 MRC-Epid JHZ

export a=/genetics/data/omics/EPICNorfolk/Axiom_UKB_EPICN_release_04Dec2014
export b=/genetics/bin/FUSION/LDREF/EUR
export w=/genetics/data/twas/25-1-18

sort -k2,2 $b.bim > LDREF.bim
sort -k2,2 $a.bim | join -j2 - LDREF.bim | cut -d' ' -f1 > LDREF.snps
rm LDREF.bim

plink-1.9 --bfile $a --extract LDREF.snps --keep $w/data/Archive/Inds.txt \
          --make-bed --threads 12 --out EPIC

## extract CpG SNPs via PLINK

export f=500000
export o=/scratch/tempjhz22/FUSION/Axiom
cat CpG.txt | parallel -j10 --env w --env f --env o -C' ' '
   export l=$(({4}-$f)); \
   if [ $l -lt 1 ]; then export l=0; fi; \
   export u=$(({4}+$f)); \
   if [ ! -d "$o/{1}" ]; then mkdir $o/{1}; fi \
   /genetics/bin/plink-1.9 --bfile $w/EPIC --make-bed --maf 0.01 \
                 --chr {3} --from-bp $l --to-bp $u --out $o/{1}/{1}'
