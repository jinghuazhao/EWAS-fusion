# 30-1-2018 MRC-Epid JHZ

export w=/genetics/data/twas/25-1-18
export m=/genetics/bin/FUSION/LDREF/EUR.bim

# obtain from map.csv: 1. CpG ID, 2. Chromosome, 3. Position

cd $w

awk -vFS="," 'NR>1{print $1,$2,$3}' data/all/map.csv > CpG.txt

# probe-specific snps; 610 CpGs have no SNP data

awk '{
  if(NR==1) print "#chrom","Start","End","CpG"
  l=$3-f
  u=$3+f
  if(l<0) l=0
  print $2,l,u,$1
}' OFS="\t" f=500000 CpG.txt > CpG.bed

awk '{
  if(NR==1) print "#chrom","Start","End","rsid"
  print $1,$4-1,$4,$2
}' OFS="\t" $m > LDREF.bed

intersectBed -a CpG.bed -b LDREF.bed -wa -wb | cut -f1,4,8 > CpG.snps.txt
cut -f1 CpG.snps.txt | uniq > CpG.list

## the following are obsolete

# STAT/Transfer to speed up CpG.do
st CpG.snps.txt CpG.snps.dta

export o=/scratch/tempjhz22/FUSION/snps

cd $o
awk '{print $2,$3}' $w/CpG.snps.txt | parallel -j10 -C' ' 'echo {2} >> {1}.snp'
