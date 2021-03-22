# stabilizing_statistics_bootstrap
R code for the simulation study and data analysis portions of "Bootstrapping Persistent Betti Numbers and other Stabilizing Statistics".

[![DOI](https://zenodo.org/badge/344289905.svg)](https://zenodo.org/badge/latestdoi/344289905)

**A makefile is included for convenience. Options are:**

make all

make bootstrap_all - Generate bootstrap samples for the simulation study

make coverage_all - Calculate coverage proportions for the simulation study

make plots - Generate figures

make galaxy - Perform bootstrap and plotting for the data analysis

make clear_logs

**Folders include:**

rscripts - script files

rout - logs

plots

galaxy - Intermediate results for the data analysis

pbetti - Intermediate results and final coverage proportions for the simulation study

**Within the rscripts folder:**

funcs.R - general functions used throughout, including persistence homology calculations

settings.R - Settings for the simulation study, including core number

settings_galaxy.R - Settings for the data analysis

cases_1-6.R, cases_1-7.R - Specifiers for the cases in the simulation study

gen_data.R - Data generating functions

galaxy.R - Data analysis
