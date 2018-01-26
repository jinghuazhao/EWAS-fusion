# 26-1-2018 MRC-Epid JHZ

# obtain CpGID, missing data indicator, chromosome, position
# 	Columns in CpG.txt: 1. CpG ID, 2. Missing value indicator
# 	Columns in map.csv: 1. CpG ID, 2. Chromosome, 3. Position

cd /genetics/data/gwas/25-1-18

function have_two_column_CpG ()
{
  sort -k1,1 /genetics/data/twas/8-12-16/CpG.txt > CpG.tmp
  awk 'NR>1' data/all/map.csv | sed 's/,/ /g' | sort -k1,1 | join CpG.tmp - | sort -k3,3n -k4,4n > CpG.txt
  rm CpG.tmp
}

# probe-specific data -- pending on missing value ability check

export p=/genetics/bin/plink-1.9
export b=/genetics/bin/FUSION/LDREF/EUR
export o=/scratch/tempjhz22/FUSION
export f=500000

cat CpG.txt | parallel -j1 --env p --env b --env f --env o -C' ' '
   export l=$(({4}-$f)); \
   if [ $l -lt 1 ]; then export l=1; fi; \
   export u=$(({4}+$f)); \
   $p --bfile $b --make-bed --maf 0.01 --chr {3} --from-bp $l --to-bp $u --out $o/{1}'

# phenotypic and covariate data for all probes in FUSION.pheno and FUSION.covar
#	residual data matrix with CpG ID as rownames and individual ID as colnames
#	Inds.txt contains individual IDs which have genomic data as well

R -q --no-save <<END
load("data/Archive/residuals")
p1 <- as.data.frame(t(mergedOut))
load("data/new/residuals")
p2 <- as.data.frame(t(mergedOut))
require(dplyr)
p <- bind_rows(p1,p2)
p[is.na(p)] <- -999
pheno <- data.frame(id=rownames(p),p)
omicsid <- read.table("data/Archive/Inds.txt",as.is=TRUE,col.names=c("z","id"))
write.table(subset(pheno,id%in%with(omicsid,id)), file="FUSION.pheno",quote=FALSE,row.names=FALSE)
END

stata <<END
use /genetics/data/omics/EPICNorfolk/EPICN_MDS_04Mar2015.dta
rename OMICS_ID omicsid
forval i=1/10 {
  rename EPICN_OMICS_PC`i' pc`i'
}
sort omicsid
save omicsid, replace
insheet z omicsid using data/Archive/Inds.txt, clear
drop z
merge 1:1 omicsid using omicsid
keep if _merge==3
outsheet omicsid omicsid pc1-pc4 using FUSION.covar, noname noquote replace
END

# simple, fast but insecure?
# load("data/Archive/residuals")
# p1 <- mergedOut
# load("data/new/residuals")
# p2 <- mergedOut
# p <- rbind(p1,p2)
# p <- t(p)
# id <- rownames(p)
# p[is.na(p)] <- -999
# pheno <- cbind(id,as.data.frame(p))
# write.table(pheno, file="FUSION.pheno",quote=FALSE,row.names=FALSE)
