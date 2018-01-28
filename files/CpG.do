// to generate list of SNPs per CpG

set more off

// insheet chr CpG rsid using CpG.snps.txt, clear
use CpG.snps.dta
rename col1 chr
rename col2 CpG
rename col3 rsid

sort CpG
egen id=group(CpG)
sum id
local N=r(max)
forval g=1/`N' {
   preserve
   keep if id==`g'
   local f=CpG
   outsheet rsid using /scratch/tempjhz22/FUSION/snps/`f'.snp, noname noquote replace
   restore
}
