#!/usr/local/bin/Rscript --vanilla
# 22-5-2017 MRC-Epid JHZ

.libPaths("/genetics/bin/R")

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]

prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste0(prefix, "/"), prefix)
ajc_file <- paste0(prefix,"assoc_joco.csv")

# uncomment if your Rmpfr is working
# library(Rmpfr)
ajc <- within(read.csv(ajc_file,as.is=TRUE),{
   logp <- -log10(TWAS.P)
#   p <- format(2*pnorm(mpfr(abs(TWAS.Z),100),lower.tail=FALSE))
#   logp <- as.numeric(-log10(mpfr(p,100)))
})

library(gap)
opar <- par()
pdf(paste0(prefix,"manhattan_plot.pdf"))
par(xpd=TRUE)
mhtplot(ajc[c("CHR","MAPINFO","logp")],mht.control(logscale=FALSE,labels=paste(1:22),gap=10000,srt=90))
axis(2)
dev.off()
par(opar)
