import delimited using data/Archive/residuals.csv, clear
save residuals, replace
import delimited using data/new/residuals.csv, clear
save new, replace
use residuals
append using new
xpose, clear varname
mvencode _all, mv(-999)
outsheet _varname using id.dat, replace noname noquote
outsheet using residuals.csv, comma replace noname noquote

