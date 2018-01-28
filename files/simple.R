setwd("/genetics/data/twas/25-1-18")

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
