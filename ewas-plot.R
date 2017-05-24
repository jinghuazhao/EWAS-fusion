#!/usr/local/bin/Rscript --vanilla
# 24-5-2017 MRC-Epid JHZ

.libPaths("/genetics/bin/R")

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]
prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste0(prefix, "/"), prefix)
ajc_file <- paste0(prefix,"ajc.csv")

use.mpfr <- FALSE
ajc <- within(read.csv(ajc_file,as.is=TRUE),{
  if (use.mpfr) {
    require(Rmpfr)
    p <- format(2*pnorm(mpfr(abs(TWAS.Z),100),lower.tail=FALSE))
    logp <- as.numeric(-log10(mpfr(p,100)))
    p2 <- format(2*pnorm(mpfr(abs(JOINT.P),100),lower.tail=FALSE))
    logp2 <- as.numeric(-log10(mpfr(p2,100)))
  } else {
    logp <- -log10(TWAS.P)
    logp2 <--log10(JOINT.P)
  }
  gene <- NA
  color <- NA
  ast <- "*"
  red <- 100
})
ord <- with(ajc,order(CHR,MAPINFO))

library(dplyr)
summarise(group_by(ajc, CHR), m = mean(logp, na.rm=TRUE), sd = sd(logp,na.rm=TRUE), 
                              min=min(logp,na.rm=TRUE), max=max(logp,na.rm=TRUE))
library(gap)
pdf(paste0(prefix,"ewas-plot.pdf"))
opar <- par()
par(cex=0.6,xpd=TRUE)
with(ajc,qqunif(TWAS.P,ci=TRUE))
title("Q-Q plot of association tests")
ops <- mht.control(colors=rep(c(107,84),11),logscale=FALSE,gap=1250,srt=0,xline=1.5,yline=1.6)
mhtplot(ajc[ord,c("CHR","MAPINFO","logp")],ops)
axis(2)
title("Manhattan plot of association tests")
ops <- mht.control(colors=rep(c(107,84),11),logscale=FALSE,gap=1250,srt=0,yline=2.5,xline=2)
mhtdata <- ajc[ord,c("CHR","MAPINFO","logp","gene","color")]
hdata <- subset(ajc[ord,c("CHR","MAPINFO","logp2","ast","red","JOINT.P")], !is.na(JOINT.P))
hops <- hmht.control(hdata)
mhtplot2(mhtdata,ops,hops,srt=0)
axis(2)
title("Manhattan plot of association and joint/conditional(*) tests")
par(opar)
dev.off()

