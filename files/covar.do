use /genetics/data/omics/EPICNorfolk/EPICN_MDS_04Mar2015.dta
rename OMICS_ID omicsid
forval i=1/10 {
  rename EPICN_OMICS_PC`i' pc`i'
}
sort omicsid
save omicsid, replace
insheet z omicsid using data/Archive/Inds.txt, clear
drop z
merge 1:1 omicsid using omicsid
keep if _merge==3
outsheet omicsid omicsid pc1-pc4 using FUSION.covar, noname noquote replace

// qctool_v2.0 assign FID as integers
