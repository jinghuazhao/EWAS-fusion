// to generate list of SNPs per CpG

set more off

use CpG.snps.dta
rename col1 chr
rename col2 CpG
rename col3 rsid

sort CpG
egen id=group(CpG)
sum id
local N=r(max)
forval g=1/`N' {
   if id==`g' {
     local f=CpG
     outsheet rsid if id==`g' using /scratch/tempjhz22/FUSION/snps/`f'.snp, noname noquote replace
   }
}
