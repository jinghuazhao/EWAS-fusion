File | Description
---------|------------
Axiom.sh | to generate binary pedigree data from Axiom chip
1KG.sh   | to generate binary pedigree data from 1KG-imputed data
covar.do | to set up covariates
 pheno.R | to generate FUSION.pheno
simple.R | simplified code for FUSION.pheno

Alhough great effort was made to develop CpG.sh and CpG.do below; they are supersed.
- CpG.sh was written to generate the following files

 .* CpG.txt - CpG ID, missing indicator, chromosome, position
 .* CpG.snps.txt - CpG - SNP correspondence
 .* CpG.snps.dta - Stata version
 .* CpG.list - CpG which contains SNPs

- CpG.do was written to produce SNP list per CpG.
