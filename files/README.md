**File** | **Description**
---------|------------
1KG.sh   | to generate binary pedigree data from 1KG-imputed data
covar.do | to set up covariates

The following files were useful during development.

* Axiom.sh - to generate binary pedigree data from Axiom chip
*  pheno.R - to generate FUSION.pheno
* simple.R - simplified code for FUSION.pheno

Program CpG.sh and CpG.do took great effort to write, but are eventually supersed.

* CpG.sh was written to generate the following files

  * CpG.txt - CpG ID, missing indicator, chromosome, position
  * CpG.snps.txt - CpG - SNP correspondence
  * CpG.snps.dta - Stata version
  * CpG.list - CpG which contains SNPs

* CpG.do was written to produce SNP list per CpG.
