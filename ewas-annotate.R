#!/usr/local/bin/Rscript --vanilla
#' EWAS-fusion Annotator -- A tool for EWAS-fusion annotation
#' Usage: ewas-annotate.R <<EWAS-fusion working directory> [manifest_location=/at/different/location]
#' @author Alexia Cardona, \email{alexia.cardona@@mrc-epid.cam.ac.uk}
#' @date May 2017

infinium_humanmethylation450_beadchip_download <- function()
{
  download.file("ftp://webdata2:webdata2@ussd-ftp.illumina.com/downloads/ProductFiles/HumanMethylation450/HumanMethylation450_15017482_v1-2.csv","HumanMethylation450_15017482_v1-2.csv")
  download.file("https://support.illumina.com/content/dam/illumina-support/documents/myillumina/4214cc3b-e52e-4ab4-a4d7-b956f62ed208/450k_manifest_header_descriptions.xlsx","450k_manifest_header_descriptions.xlsx")
}

args <- commandArgs(trailingOnly = FALSE)
manifest_location <- dirname(sub("--file=", "", args[grep("--file", args)]))

args <- strsplit(commandArgs(TRUE), split='=')
keys <- vector("character")
if (length(args) > 0) for (i in 1:length(args)) {
    key <- args[[i]][1]
    value <- args[[i]][2]
    keys <- c(keys, key)
    if (exists(key)) assign(key, value)
  }

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]
prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste0(prefix, "/"), prefix)
if(is.na(prefix)) {
  cat("\n")
  cat("Usage: ewas-annotate.R directory.name\n")
  cat("where directory.name contains results from ewas-fusion.sh\n\n")
  quit("yes")
}

# User messages
options(echo=FALSE)
cat("EWAS-fusion Annotator -- A tool for EWAS-fusion annotation
(based on Illumina Infinium HumanMethylation450 Manifest file version 1.2)\n
Alexia Carona, PhD\nEmail: alexia.cardona@@mrc-epid.cam.ac.uk\n
Annotating files in", prefix, "...\n\n")

# Manifest information
anno <- read.csv(paste0(manifest_location,"/HumanMethylation450_15017482_v1-2.csv"),as.is=TRUE, skip=7)
anno <- subset(anno, CHR!="X"&CHR!="Y")
anno <- within(anno, {CHR=as.numeric(CHR)})

# Results from all chromosomes
temp <- NULL
for(i in 1:22)
{
  temp <- rbind(temp, read.table(paste0(prefix, i, ".dat"), as.is=TRUE, header=TRUE))
}
library(reshape)
temp <- rename(temp, c("CHR"="CHR_fusion","ID"="Name"))

# Annotation
annotated.data <- merge(temp, anno, by="Name")
N <- nrow(annotated.data)

# P-values, Bonferroni-corrected significant list and joint/conditional analysis
sorted.data <- annotated.data[with(annotated.data,order(TWAS.P)),]
write.csv(sorted.data, file=paste0(prefix, "annotatedSorted.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("All annotation: ", prefix, "annotatedSorted.csv\n"))

sig.data <- subset(sorted.data, TWAS.P <= 0.05/N)
write.csv(sig.data, file=paste0(prefix, "annotatedSortedSignificant.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("Bonferroni-corrected significant list: ", prefix, "annotatedSortedSignificant.csv\n"))

included <- dropped <- NULL
for (i in 1:22)
{
  included <- rbind(included, read.table(paste0(prefix, i, ".top.analysis.joint_included.dat"), as.is=TRUE, header=TRUE))
  dropped <- rbind(dropped, read.table(paste0(prefix, i, ".top.analysis.joint_dropped.dat"), as.is=TRUE, header=TRUE))
}
included <- rename(included, c("ID"="Name"))
j <- merge(included, anno, by="Name")
sorted.data <- j[with(j,order(JOINT.P)),]
write.csv(sorted.data, file=paste0(prefix, "annotatedJoint_included.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("Joint annotation: ", prefix, "annotatedJoint_included.csv\n"))
dropped <- rename(dropped, c("ID"="Name"))
c <- merge(dropped, anno, by="Name")  
sorted.data <- c[with(c,order(COND.P)),]
write.csv(sorted.data, file=paste0(prefix, "annotatedJoint_dropped.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("Conditional annotation: ", prefix, "annotatedJoint_dropped.csv\n"))

annotated.data <- within(annotated.data, {TWAS.P.Bonferroni <- 0.05/N})
included <- included[setdiff(names(included),c("FILE","TWAS.Z","TWAS.P"))]
aj <- merge(annotated.data, included, by="Name", all=TRUE)
dropped <- dropped[setdiff(names(dropped),c("FILE","TWAS.Z","TWAS.P"))]
ajc <- merge(aj, dropped, by="Name", all=TRUE)
ajc <- ajc[with(ajc,order(CHR,MAPINFO)),]
write.csv(ajc,file=paste0(prefix,"ajc.csv"),quote=FALSE, row.names=FALSE)
cat(paste0("Association + Joint/conditional annotation: ", prefix, "ajc.csv\n"))
cat("\nThe annotation is done.\n\n")
rm(prefix, temp, included, dropped, anno, annotated.data, sorted.data, sig.data, j, c, aj, ajc)

cat("Further information about FUSION and annotation is available from\n
http://gusevlab.org/projects/fusion/
https://support.illumina.com/array/array_kits/infinium_humanmethylation450_beadchip_kit/downloads.html\n\n")
