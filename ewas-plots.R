#!/usr/local/bin/Rscript --vanilla
# 23-5-2017 MRC-Epid JHZ

.libPaths("/genetics/bin/R")

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]
prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste0(prefix, "/"), prefix)
ajc_file <- paste0(prefix,"ajc.csv")

high.prec <- FALSE
ajc <- within(read.csv(ajc_file,as.is=TRUE),{
  if (!high.prec)
  {
    logp <- -log10(TWAS.P)
  } else {
    require(Rmpfr)
    p <- format(2*pnorm(mpfr(abs(TWAS.Z),100),lower.tail=FALSE))
    logp <- as.numeric(-log10(mpfr(p,100)))
  }
})

opar <- par()
pdf(paste0(prefix,"ewas-plots.pdf"))
library(gap)
par(cex=0.4,xpd=TRUE)
with(ajc,qqunif(TWAS.P,ci=TRUE))
mhtplot(ajc[c("CHR","MAPINFO","logp")],mht.control(logscale=FALSE,labels=paste(1:22),gap=2500,srt=90))
axis(2)
dev.off()
par(opar)
