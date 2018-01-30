**File** | **Description**
---------|------------
CpG.sh   | to generate CpG.txt from map.csv indicating CpG ID, chromosome, position
1KG.sh   | to generate binary pedigree data from 1KG-imputed data
covar.do | to set up FUSION.covar
simple.R | to set up FUSION.pheno

CpG.sh also generates the following files,

  * CpG.snps.txt - CpG - SNP correspondence
  * CpG.snps.dta - Stata version
  * CpG.list - CpG which contains SNPs

The following files were useful during development.

* Axiom.sh - to generate binary pedigree data from Axiom chip
*  ~~pheno.R~~ - to generate FUSION.pheno
*  ~~pheno.do~~ - to generate FUSION.pheno
* ~~CpG.do~~ - to produce SNP list per CpG

The major consideration not to use them is the computing resources they need.
