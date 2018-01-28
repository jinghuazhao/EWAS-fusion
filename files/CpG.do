// to generate list of SNPs per CpG

set more off

use CpG.snps.dta
rename col1 chr
rename col2 CpG
rename col3 rsid
sort chr CpG

forval x=1/22 {
   levelsof CpG if chr==`x', local(CpGi)
   foreach i in `CpGi' {  
     outsheet rsid if CpG=="`i'" using /scratch/tempjhz22/FUSION/snps/`i'.snp, /*
           */ noname noquote replace
   }
}

/*
insheet col1-col3 CpG rsid using CpG.snps.txt, clear
egen id=group(col2)
sum id
local N=r(max)
forval g=1/`N' {
   use CpG.snps.dta if id==`g'
   local f=col2
   outsheet col3 using /scratch/tempjhz22/FUSION/snps/`f'.snp, noname noquote replace
}
*/
