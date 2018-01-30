# 30-1-2018 MRC-Epid JHZ

setwd("/genetics/data/twas/25-1-18")

load("data/Archive/residuals")
p1 <- mergedOut
load("data/new/residuals")
p2 <- mergedOut
names(p1)!=names(p2)
p <- rbind(p1,p2)
p[is.na(p)] <- -999
q <- t(p)
q <- as.data.frame(q)
pheno <- data.frame(FID=rownames(q), IID=rownames(q), q)
Ind <- read.table("Inds.dat",as.is=TRUE)
write.table(subset(pheno,FID%in%Ind), file="FUSION.pheno",quote=FALSE,row.names=FALSE, sep="\t")
