#!/usr/local/bin/Rscript --vanilla
#' EWAS-fusion Annotator -- A tool for EWAS-fusion annotation
#' Argument: path to the EWAS-fusion output
#' @author Alexia Cardona, \email{alexia.cardona@@mrc-epid.cam.ac.uk}
#' @date May 2017

EWAS_fusion <- "/genetics/bin/EWAS-fusion"
infinium_humanmethylation450_beadchip_download <- function()
# see also /genetics/data/twas/doc
{
  download.file("ftp://webdata2:webdata2@ussd-ftp.illumina.com/downloads/ProductFiles/HumanMethylation450/HumanMethylation450_15017482_v1-2.csv","HumanMethylation450_15017482_v1-2.csv")
  download.file("https://support.illumina.com/content/dam/illumina-support/documents/myillumina/4214cc3b-e52e-4ab4-a4d7-b956f62ed208/450k_manifest_header_descriptions.xlsx","450k_manifest_header_descriptions.xlsx")
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

# Messages to users
options(echo=FALSE)
cat("EWAS-fusion Annotator -- A tool for EWAS-fusion annotation
(based on Illumina's Manifest file version 1.2)\n
by Alexia Carona, PhD\n
Annotating files in", prefix, "...\n\n")

# Merge chromosomes
temp <- NULL
for(i in 1:22) 
{
  temp <- rbind(temp, read.table(paste0(prefix, i, ".dat"), as.is=TRUE, header=TRUE))
}

# Annotate files
anno <- read.csv(paste0(EWAS_fusion,"/HumanMethylation450_15017482_v1-2.csv"),as.is=TRUE, skip=7)
colnames(temp)[2] <- "Name"
annotated.data <- merge(temp, anno, by="Name")
rm(temp)

# Sort by P-value
sorted.data <- annotated.data[order(annotated.data$TWAS.P),]
rm(annotated.data)
write.csv(sorted.data, file=paste0(prefix, "annotatedSorted.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("Annotated results for all chromosmes are in ", prefix, "annotatedSorted.csv\n"))

# Get list of significant CpGs
sig.data <- subset(sorted.data, TWAS.P < (0.05/nrow(sorted.data)))
write.csv(sig.data, file=paste0(prefix, "annotatedSortedSignificant.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("Bonferroni significant list is ", prefix, "annotatedSortedSignificant.csv\n"))
rm(sorted.data)
rm(sig.data)

# Work on joint/conditional analysis
temp <- NULL
for (i in 1:22)
{
  temp <- rbind(temp, read.table(paste0(prefix, i, ".top.analysis.joint_included.dat"), as.is=TRUE, header=TRUE))
}

# Annotate files
colnames(temp)[2] <- "Name"
annotated.data <- merge(temp, anno, by="Name")
rm(temp)

sorted.data <- annotated.data[order(annotated.data$JOINT.P),]
write.csv(sorted.data, file=paste0(prefix, "annotatedJoint_included.csv"), quote=FALSE, row.names=FALSE)
cat(paste0("Annotated joint/conditional analysis results in ", prefix, "annotatedJoint_included.csv\n"))
rm(sorted.data)

cat("\nThe annotation is done.\n\n")
cat("For more information about FUSION and the headings in the output please visit\n
http://gusevlab.org/projects/fusion/
https://support.illumina.com/array/array_kits/infinium_humanmethylation450_beadchip_kit/downloads.html\n\n")
