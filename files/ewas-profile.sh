#27-2-2018 MRC-Epid JHZ

# ls EWAS-weights | sort -k1,1 > EWAS-weights.list
find EWAS-weights -name "*.RDat" -print | xargs -l basename > EWAS-weights.list

export wd=/genetics/bin/EWAS-fusion
cd $wd/EWAS-weights
FUSION.profile_wgt.R $wd/EWAS-weights.list > $wd/EWAS-weights.profile
cd -

stata <<EOF
insheet using /genetics/data/twas/8-12-16/pos.dat, case clear
sort ID
save pos, replace
insheet ID using EWAS-weights.list, case clear
replace ID=subinstr(ID, "./", "",.)
replace ID=subinstr(ID, ".wgt.RDat","",.)
sort ID
merge 1:1 ID using pos
sort CHR
outsheet WGT ID CHR P0 P1 using EWAS-weights.pos if _merge==3, noquote replace
erase pos.dta
/*pos.dat*/
/*
WGT	ID	CHR	P0	P1
cg00000165.wgt.RDat	cg00000165	1	90694674	91694674
cg00000363.wgt.RDat	cg00000363	1	230060793	231060793
cg00001364.wgt.RDat	cg00001364	1	213670376	214670376
cg00001446.wgt.RDat	cg00001446	1	43331041	44331041
...
*/
EOF

# create glist-hg19 (analogously!)

awk -vFS="\t" '(NR>1){print $3,$4,$5,$2}' EWAS-weights.pos > glist-hg19

if [ ! -d LDREF ]; then mkdir LDREF; fi
cd LDREF
wget -qO- https://data.broadinstitute.org/alkesgroup/FUSION/LDREF.tar.bz2 | tar xfj - --strip-components=1
seq 22|awk -vp=1000G.EUR. '{print p $1}' > merge-list
plink-1.9 --merge-list merge-list --make-bed --out EUR
cd -
sort -k2,2 LDREF/EUR.bim > EUR.bim
