# 6-7-2021 JHZ

function index()
{
  Rscript -e "knitr::knit(\"README.Rmd\")"
  pandoc README.md --self-contained  --citeproc --mathjax -s -o index.html
  cp README.md docs
}

mkdocs build
mkdocs gh-deploy

git add .gitignore
git commit -m ".gitignore"
git add CLEAN_ZSCORES.awk
git commit -m "strand alignment"
git add ewas-annotate.R
git commit -m "EWAS annotation"
git add ewas-fusion.qsub
git commit -m "sge"
git add ewas-fusion.sh
git commit -m "Bash driver"
git add ewas-fusion.slurm
git commit -m "SLURM"
git add ewas-fusion.subs
git commit -m "subroutine"
git add ewas-plot.R
git commit -m "EWAS plot"
git add get_weight.qsub
git commit -m "Generating weights"
git add README.Rmd README.md EWAS-fusion.bib american-journal-of-medical-genetics.csl
git commit -m "README"
git add README.pptx
git commit -m "PPT"
git add files
git commit -m "auxiliary files"
git add test.sh
git commit -m "test"
git add mkdocs.yml
git commit -m "mkdocs.ytml"
git push
