// to generate list of SNPs per CpG

set more off

use CpG.snps.dta
rename col1 chr
rename col2 CpG
rename col3 rsid

sort CpG
egen id=group(CpG), label
sum id
forval group=1/r(max) {
   if (id==`group') {
     local f=CpG
     outsheet rsid using /scratch/tempjhz22/FUSION/snps/`f'.snp, noname noquote replace
   }
}
