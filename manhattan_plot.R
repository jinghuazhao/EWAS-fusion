#!/usr/local/bin/Rscript --vanilla
# 22-5-2017 MRC-Epid JHZ

.libPaths("/genetics/bin/R")

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]

prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste0(prefix, "/"), prefix)
ajc_file <- paste0(prefix,"assoc_joco.csv")

ajc <- within(read.csv(ajc_file,as.is=TRUE),{logp <- -log10(TWAS.P)})
library(gap)
opar <- par()
par(xpd=TRUE)
pdf(paste0(prefix,"manhattan_plot.pdf"))
mhtplot(ajc[c("CHR","MAPINFO","logp")],mht.control(logscale=FALSE,labels=paste(1:22),gap=10000,srt=90))
axis(2)
dev.off()
par(opar)
