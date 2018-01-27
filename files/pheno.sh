# 27-1-2018 MRC-Epid

# phenotypic and covariate data for all probes in FUSION.pheno and FUSION.covar
#	residual data matrix with CpG ID as rownames and individual ID as colnames

setwd("/genetics/data/twas/25-1-18")

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
