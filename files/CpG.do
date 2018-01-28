// to generate list of SNPs per CpG

set more off

// insheet col1-col3 CpG rsid using CpG.snps.txt, clear
use CpG.snps.dta
sort col2
egen id=group(col2)
save CpG.snps.dta, replace

sum id
local N=r(max)
forval g=1/`N' {
   use CpG.snps.dta if id==`g'
   local f=col2
   outsheet col3 using /scratch/tempjhz22/FUSION/snps/`f'.snp, noname noquote replace
}
