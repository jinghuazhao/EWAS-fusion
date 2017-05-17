#!/usr/local/bin/Rscript --vanilla
#' EWAS-fusion Annotator
#' 
#' Annotates the EWAS-fusion output files with Illumina's Manifest file version 1.2.
#' Argument:  the script takes the path of where the EWAS-fusion  output files are saved.
#' @author Alexia Cardona, \email{alexia.cardona@@mrc-epid.cam.ac.uk}
#' @date May 2017

args <- commandArgs(trailingOnly=TRUE)
prefix <- args[1]
prefix <- ifelse(substring(prefix,nchar(prefix)) != "/", paste(sep="", prefix, "/"), prefix)
if(is.na(prefix)) {
	cat("\n")
	cat("Usage: Annotate.R directory.name\n")
	cat("where directory.name contains results from ewas-fusion.sh\n\n")
	quit("yes")
}

#Message to users
cat("EWAS-fusion Annotator - a utility to annotate results from the EWAS-fusion pipeline.\n")
cat("by Alexia Carona, PhD\n\n")
cat("For more information about the headings in the output please visit\n")
cat("https://support.illumina.com/array/array_kits/infinium_humanmethylation450_beadchip_kit/downloads.html\n")
cat("\nor check\n\n/genetics/bin/EWAS-fusion/450k_manifest_header_descriptions.xlsx\n")
cat("\nand\n\n")
cat("http://gusevlab.org/projects/fusion/\n\n\n\n")
cat("Annotating", prefix, " ....\n")

#merge chromosomes
temp <- NULL
for(i in 1:22) 
{
	temp <- rbind(temp, read.table(paste0(prefix, i, ".dat"), as.is=TRUE, header=TRUE))
}

#annotate files
anno <- read.csv("/genetics/bin/EWAS-fusion/HumanMethylation450_15017482_v1-2.csv",as.is=TRUE, skip=7)
colnames(temp)[2] <- "Name"
annotated.data <- merge(temp, anno, by="Name")
rm(temp) #free memory

#sort by P-value
sorted.data <- annotated.data[order(annotated.data$TWAS.P),]
rm(annotated.data) #free memory
write.csv(sorted.data, file=paste(sep="", prefix, "annotatedSorted.csv"), quote=FALSE, row.names=FALSE)
cat(paste(sep="", "Annotated EWAS-fusion results for all chromosmes are in ", prefix, "annotatedSorted.csv\n"))

#get list of significant CpGS
sig.data <- subset(sorted.data, TWAS.P < (0.05/nrow(sorted.data)))
write.csv(sig.data, file=paste(sep="", prefix, "annotedSortedSignificant.csv"), quote=FALSE, row.names=FALSE)
cat(paste(sep="", "Bonferroni significant list in ", prefix, "annotatedSortedSignificant.csv\n"))
rm(sorted.data) #free memory
rm(sig.data)


################################################
#Joint/conditional analysis

cat("Processing Joint/conditional analysis results\n\n")
cat("Annotating", prefix, "....\n")

temp <- NULL
for (i in 1:22)
{
	temp <- rbind(temp, read.table(paste(sep="", prefix, i, ".top.analysis.joint_included.dat"), header=TRUE))
}

#annotate files
colnames(temp)[2] <- "Name"
annotated.data <- merge(temp, anno, by="Name")
rm(temp) #free memory

sorted.data <- annotated.data[order(annotated.data$JOINT.P),]
write.csv(sorted.data, file=paste(sep="", prefix, "annotatedJoint_included.csv"), quote=FALSE, row.names=FALSE)
cat(paste(sep="", "Annotated Joint/Conditional analysis results in ", prefix, "annotatedJoint_included.csv\n"))
rm(sorted.data) #free memory

infinium_humanmethylation450_beadchip_setup <- function()
# also see /genetics/data/twas/doc
{
	hmv12 <-"ftp://webdata2:webdata2@ussd-ftp.illumina.com/downloads/ProductFiles/HumanMethylation450/HumanMethylation450_15017482_v1-2.csv"
	download.file(hmv12,"HumanMethylation450_15017482_v1-2.csv")
	mhd <- "https://support.illumina.com/content/dam/illumina-support/documents/myillumina/4214cc3b-e52e-4ab4-a4d7-b956f62ed208/450k_manifest_header_descriptions.xlsx"
	download.file(mhd,"450k_manifest_header_descriptions.xlsx")
}
