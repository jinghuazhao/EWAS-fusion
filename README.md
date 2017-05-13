# EWAS-fusion

The respository is for Epigenome-wide association study (EWAS) - Functional Summary-based Imputation (FUSION) association and joint/conditional analyses.

## Requirements

To begin, the software [FUSION](http://gusevlab.org/projects/fusion/) including its dependencies such as `plink2R` is required. Other facilities to be required are

1. Sun grid engine (sge) or GNU parallel for Linux clusters.
2. Weight files based on epigenetic data.

FILE | Description
-----|---------------------------
EWAS/ | directory for EWAS weights
EWAS.bim | SNP information file
glist-hg19 | Probe list
LDREF/ | Reference for LD
RDat.pos | Definition of regions
RDat.profile* | Probe profiles

* It contains information about the probes but not directly involved in the association analysis.

## Input

The input file contains GWAS summary statistics similar to [.sumstats](https://github.com/bulik/ldsc/wiki/Summary-Statistics-File-Format) as in [LDSC](https://github.com/bulik/ldsc) with the following columns.

   Column | Description
   ------|--------------  
   SNP | RS id of SNPs
   A1 | Effect allele (first allele)
   A2 | Other allele (second allele)
   Z | Z-scores, taking sign with repect to A1

## Use of the programs
```
ewas-fusion.sh input-file
```
These will send jobs to the Linux clusters. The sge error and output, if any, should be called EWAS.e and EWAS.o in your HOME directory.

## Output

The results will be in input-file.tmp/ directory.

## Example

The script [test.sh](test.sh) uses [height data](http://portals.broadinstitute.org/collaboration/giant/images/0/01/GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz) from GIANT.
```
#!/bin/bash
# 11-5-2017 MRC-Epid JHZ

wget http://portals.broadinstitute.org/collaboration/giant/images/0/01/GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz
gunzip -c GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz | \
awk '{
  FS=OFS="\t";
  t=NR
  if(NR==1) print "SNP","A1","A2","Z"
  else print $1,$2,$3,$5/$6
}' | sort -k1,1 > height

ewas-fusion.sh height
rm GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz height
```
It first downloads the data containing GWAS summary statistics, to be unzipped and directed to a file called `height` as an input to `ewas-fusion.sh. The results will be in height.tmp/ once it is done.

## References

Gusev A, et al. (2016). Integrative approaches for large-scale transcriptome-wide association studies. Nature Genetics, 48, 245-252

Mancuso N, et al. (2017). Integrating gene expression with summary association statistics to identify susceptibility genes for 30 complex traits. American Journal of Human Genetics, 2017, 100, 473-487, http://www.cell.com/ajhg/fulltext/S0002-9297(17)30032-0. See also http://biorxiv.org/content/early/2016/09/01/072967 or http://dx.doi.org/10.1101/072967.

Wood AR, et al. (2014). Defining the role of common variation in the genomic and biological architecture of adult human height (2014). Nature Genetics 46, 1173-1186.

## Acknowledgement

We wish to thank colleagues and collaborators to make this work possible.
