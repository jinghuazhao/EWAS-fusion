# 26-1-2018 MRC-Epid JHZ

# Columns in CpG.txt
#
#	1. CpG ID
#	2. Missing value indicator
#
# Columns in map.csv:
#
#	1. CpG ID
#	2. Chromosome
#	3. Position
#
# obtain CpGID, missing data indicator, chromosome, position

function have_two_column_CpG ()
{
  sort -k1,1 /genetics/data/twas/8-12-16/CpG.txt > CpG.tmp
  awk 'NR>1' /genetics/data/twas/25-1-18/data/all/map.csv | sed 's/,/ /g' | sort -k1,1 | join CpG.tmp - | sort -k3,3n -k4,4n > CpG.txt
  rm CpG.tmp
}

# produce probe-specific data

export p=/genetics/bin/plink-1.9
export b=/genetics/bin/FUSION/LDREF/EUR
export o=/scratch/tempjhz22/FUSION
export f=500000

cat CpG.txt | parallel -j1 --env p --env b --env f --env o -C' ' '
   export l=$(({4}-$f)); \
   if [ $l -lt 1 ]; then export l=1; fi; \
   export u=$(({4}+$f)); \
   $p --bfile $b --make-bed --maf 0.01 --chr {3} --from-bp $l --to-bp $u --out $o/{1}'

# produce phenotypic and covariate data for all probes in FUSION.pheno and FUSION.covar

R -q --no-save <<END
load("data/Archive/residuals")
p1 <- mergedOut
load("data/new/residuals")
p2 <- mergedOut
p <- rbind(p1,p2)
p <- t(p)
id <- rownames(p)
p[is.na(p)] <- -999
pheno <- cbind(id,as.data.frame(p))
write.table(pheno, file="FUSION.pheno",quote=FALSE,row.names=FALSE)
END

# Now we are ready to obtain weights!
