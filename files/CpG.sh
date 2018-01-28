# 28-1-2018 MRC-Epid JHZ

# obtain CpGID, missing data indicator, chromosome, position
# 	Columns in CpG.txt: 1. CpG ID, 2. Missing value indicator
# 	Columns in map.csv: 1. CpG ID, 2. Chromosome, 3. Position

cd /genetics/data/twas/25-1-18

sort -k1,1 /genetics/data/twas/8-12-16/CpG.txt > CpG.tmp
awk 'NR>1' data/all/map.csv | sed 's/,/ /g' | \
sort -k1,1 | join CpG.tmp - | sort -k3,3n -k4,4n > CpG.txt
rm CpG.tmp

# probe-specific snps; 610 CpGs have no SNP data

awk '{
  if(NR==1) print "#chrom","Start","End","CpG"
  l=$4-f
  u=$4+f
  if(l<0) l=0
  print $3,l,u,$1
}' OFS="\t" f=500000 CpG.txt > CpG.bed

awk '{
  if(NR==1) print "#chrom","Start","End","CpG"
  print $1,$4-1,$4,$2
}' OFS="\t" /genetics/bin/FUSION/LDREF/EUR.bim > EUR.bed

intersectBed -a CpG.bed -b EUR.bed -wa -wb | cut -f1,4,8 > CpG.snps.txt
cut -f1 CpG.snps.txt | uniq > CpG.list

# STAT/Transfer to speed up CpG.do
# st CpG.snps.txt CpG.snps.dta

awk '{print $1,$2,$3}' CpG.snps.txt | parallel -j5 -C' ' '
    cd /scratch/tempjhz22/FUSION/snps;rm -f {2}.snp; touch {2}.snp'
awk '{print $1,$2,$3}' CpG.snps.txt | parallel -j5 -C' ' '
    cd /scratch/tempjhz22/FUSION/snps;echo {3} >> {2}.snp'


