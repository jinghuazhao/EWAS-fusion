# 29-1-2018 MRC-Epid JHZ

export i=/gen_omics/data/EPIC-Norfolk/imputedfiles_parts/
export b=/genetics/bin/FUSION/LDREF/1000G.EUR
export o=/scratch/tempjhz22/LDcalc/Omics
export w=/genetics/data/twas/25-1-18

# 1KG-imputed genotypes

## qctool-style keep list

cut -f2 data/Archive/Inds.txt > Inds.dat

## obtain snpstats for all variants

seq 22 | parallel -j1 --env i --env o --env w -C' ' '
    /genetics/bin/qctool_v2.0 -filetype bgen -g $i/chr{}.bgen -s $i/EPICNorfolk.sample \
         -incl-samples $w/Inds.dat -snp-stats -osnp $o/chr{}.snpstats'

## binary ped for all variants

seq 22 | parallel -j1 --env i --env b --env o -C' ' '
   cut -f2 $b.{}.bim > $o/LDREF{}.snps; \
   qctool_v2.0 -filetype bgen -g $i/chr{}.bgen -s $i/EPICNorfolk.sample \
               -ofiletype binary_ped -og $o/chr{} -incl-samples Inds.dat \
               -incl-rsids $o/LDREF{}.snps -threads 5'

## merge from all chromosomes

seq 22 | awk -vo=$o '{print o "/chr" $1}' > merge-list
plink-1.9 --merge-list merge-list --make-bed --out $o/EPIC

## overlap list of variants with LDREF and binary ped

export a=$o/EPIC
export b=/genetics/bin/FUSION/LDREF/EUR

sort -k2,2 $b.bim > LDREF.bim
sort -k2,2 $a.bim | join -j2 - LDREF.bim | cut -d' ' -f1 > LDREF.snps
rm LDREF.bim

plink-1.9 --bfile $a --extract LDREF.snps --make-bed --threads 12 --out EPIC

## variant exclusion list

seq 22 | parallel -j5 --env o -C' ' 'awk "NR>12 && (\$14<0.01||\$18<0.4||\$19>=0.05){print \$2}" $o/chr{}.snpstats | \
sort -k1,1 | join -j1 - LDREF.snps > $o/chr{}.excl'

## extract per CpG SNPs via PLINK

export f=500000
export O=/scratch/tempjhz22/FUSION/1KG
cat CpG.txt | parallel -j10 --env w --env f --env o -C' ' '
   export l=$(({4}-$f)); \
   if [ $l -lt 1 ]; then export l=0; fi; \
   export u=$(({4}+$f)); \
   if [ ! -d "$O/{1}" ]; then mkdir $O/{1}; fi; \
   /genetics/bin/plink-1.9 --bfile EPIC --make-bed --exclude $o/chr{3}.excl \
                 --chr {3} --from-bp $l --to-bp $u --out $O/{1}/{1}'

# format of snpstats
# snpstats <- read.table("chr22.snpstats",as.is=TRUE,header=TRUE,skip=11)
# 2 "rsid"
# 3 chromosome
# 4 position
# 5 alleleA
# 6 alleleB
# 8 "HW_exact_p_value"
# 14 "minor_allele_frequency"
# 18 "impute_info"
# 19 "missing_proportion"
# snpid <- paste0(chromosome,position,ifelse(alleleA<alleleB,paste0("_",alleleA,"_",alleleB),paste0("_",alleleB,"_",alleleA)))
