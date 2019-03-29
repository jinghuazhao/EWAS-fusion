#!/usr/local/bin/Rscript --vanilla
# 29-3-2019 JHZ
# 30-5-2017 MRC-Epid JHZ

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]
prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste0(prefix, "/"), prefix)
ajc_file <- paste0(prefix,"ajc.csv")

ajc <- within(read.csv(ajc_file, as.is=TRUE), {
  p <- p2 <- p3 <- logP <- logp <- logp2 <- logp3 <- gene <- colors <- NA
  ast <- astplus <- ""
  red <- 100
})
c1 <- with(ajc, !is.na(EWAS.Z))
c2 <- with(ajc, !is.na(JOINT.Z))
c3 <- with(ajc, !is.na(COND.Z))

use.mpfr <- TRUE
if(use.mpfr) {
  require(Rmpfr)
  ajc[c1, "p"] <- format(2*pnorm(mpfr(abs(ajc[c1,"EWAS.Z"]),100),lower.tail=FALSE))
  ajc[c1, "logp"] <- as.numeric(-log10(mpfr(ajc[c1,"p"],100)))
  ajc[c2, "p2"] <- format(2*pnorm(mpfr(abs(ajc[c2,"JOINT.Z"]),100),lower.tail=FALSE))
  ajc[c2, "logp2"] <- as.numeric(-log10(mpfr(ajc[c2,"p2"],100)))
  ajc[c3, "p3"] <- format(2*pnorm(mpfr(abs(ajc[c3,"COND.Z"]),100),lower.tail=FALSE))
  ajc[c3, "logp3"] <- as.numeric(-log10(mpfr(ajc[c3,"p3"],100)))
} else {
  ajc[c1, "logp"] <- -log10(ajc[c1,"EWAS.P"])
  ajc[c2, "logp2"] <- -log10(ajc[c2,"JOINT.P"])
  ajc[c3, "logp3"] <- -log10(ajc[c3,"COND.P"])
}
ajc[c2, "logP"] <- ajc[c2, "logp2"]
ajc[c3, "logP"] <- ajc[c3, "logp3"]
ca <- with(ajc, !is.na(EWAS.P) & EWAS.P<=EWAS.P.Bonferroni)
ajc[ca, "ast"] <- "*"
ajc[c2, "astplus"] <- "j"
ajc[c3, "astplus"] <- "c"

library(dplyr)
ajc <- subset(ajc, !is.na(logp))
cat("\nSummary statistics for -log10(p)\n\n")
print(summarise(group_by(ajc, CHR), m = mean(logp), sd = sd(logp), min=min(logp), max=max(logp)), n=22)
cat("\n")
library(gap)
pdf(paste0(prefix,"ewas-plot.pdf"))
opar <- par()
par(cex=0.6,xpd=TRUE)
with(ajc,qqunif(EWAS.P,ci=TRUE))
title("Association tests")
colors <- rep(c(107,84),11)
hline <- -log10(ajc[1,"EWAS.P.Bonferroni"])
ops <- mht.control(colors=colors,logscale=FALSE,gap=1250,srt=0,xline=1.5,yline=1.6,cutoffs=hline)
mhtdata <- ajc[c("CHR","MAPINFO","logp","gene","colors")]
hdata <- subset(ajc, EWAS.P<=EWAS.P.Bonferroni)[c("CHR","MAPINFO","logp","ast","red","Name")]
dim(hdata)
hops <- hmht.control(hdata)
mhtplot2(mhtdata,ops)
axis(2)
title("Association tests")
library(qqman)
qd <- ajc[c("Name","CHR","MAPINFO","logp","EWAS.Z")]
names(qd) <- c("SNP","CHR","BP","logp","zscore")
manhattan(qd,highlight=with(hdata,Name),p="logp",logp=FALSE,main="Association tests",
          enomewideline = FALSE, suggestiveline = FALSE, ylim=c(0,100))
ops <- mht.control(colors=colors,logscale=FALSE,gap=1250,srt=0,xline=2,yline=2.5,cutoffs=hline)
mhtdata <- ajc[c("CHR","MAPINFO","logp","gene","colors")]
hdata <- subset(ajc, !is.na(JOINT.P)|!is.na(COND.P))[c("CHR","MAPINFO","logP","astplus","red")]
hops <- hmht.control(hdata)
mhtplot2(mhtdata,ops,hops)
axis(2)
title("Association and (j)oint/(c)onditional tests")
par(opar)
dev.off()
