// to combine two-part available files

import delimited using data/Archive/residuals.csv, clear
save residuals, replace
import delimited using data/new/residuals.csv, clear
save new, replace

use residuals
append using new, force
mvencode _all, mv(-999)
rename v1 CpGid
outsheet using residuals.csv, comma replace noname noquote

// Stata cannot perform xpose since it exceeds maxvar
