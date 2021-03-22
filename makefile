.PHONY: all bootstrap_all coverage_all clear_logs galaxy plots

EMAIL=
SERVER=

R = R --vanilla --file=rscripts/$(1) > rout/$(1).out
MAIL = $(if $(EMAIL), mail -s $(1) ${EMAIL} <<< "$(1) has finished running on ${SERVER}.")


all: coverage_all plots galaxy
bootstrap_all: pbetti/reps/bootstrap_hpi pbetti/reps/bootstrap_hlscv pbetti/reps/bootstrap_hscv pbetti/reps/bootstrap_adapt pbetti/reps/bootstrap_silv
coverage_all: pbetti/coverage_hpi.csv pbetti/coverage_hlscv.csv pbetti/coverage_hscv.csv pbetti/coverage_adapt.csv pbetti/coverage_silv.csv
plots: plots/plot_bootstrap_comp.pdf
galaxy: galaxy/galaxy
clear_logs:
	rm rout/*.out

rscripts/pbetti_mean.R: rscripts/gen_data.R rscripts/settings.R rscripts/funcs.R rscripts/cases_1-7.R

rscripts/bootstrap_hpi.R: rscripts/gen_data.R rscripts/settings.R rscripts/funcs.R rscripts/cases_1-6.R
rscripts/bootstrap_hlscv.R: rscripts/gen_data.R rscripts/settings.R rscripts/funcs.R rscripts/cases_1-6.R
rscripts/bootstrap_hscv.R: rscripts/gen_data.R rscripts/settings.R rscripts/funcs.R rscripts/cases_1-6.R
rscripts/bootstrap_adapt.R: rscripts/gen_data.R rscripts/settings.R rscripts/funcs.R rscripts/cases_1-6.R
rscripts/bootstrap_silv.R: rscripts/gen_data.R rscripts/settings.R rscripts/funcs.R rscripts/cases_1-7.R

rscripts/coverage_hpi.R: rscripts/settings.R rscripts/cases_1-6.R
rscripts/coverage_hlscv.R: rscripts/settings.R rscripts/cases_1-6.R
rscripts/coverage_hscv.R: rscripts/settings.R rscripts/cases_1-6.R
rscripts/coverage_adapt.R: rscripts/settings.R rscripts/cases_1-6.R
rscripts/coverage_silv.R: rscripts/settings.R rscripts/cases_1-7.R

rscripts/plots.R: rscripts/gen_data.R rscripts/funcs.R

rscripts/galaxy.R: rscripts/funcs.R rscripts/settings_galaxy.R

pbetti/pbetti_mean.csv: rscripts/pbetti_mean.R
	$(call R,pbetti_mean.R)
	$(call MAIL,pbetti_mean.R)

pbetti/reps/bootstrap_hpi: rscripts/bootstrap_hpi.R
	$(call R,bootstrap_hpi.R)
	$(call MAIL,bootstrap_hpi.R)
	touch pbetti/reps/bootstrap_hpi
pbetti/reps/bootstrap_hlscv: rscripts/bootstrap_hlscv.R
	$(call R,bootstrap_hlscv.R)
	$(call MAIL,bootstrap_hlscv.R)
	touch pbetti/reps/bootstrap_hlscv
pbetti/reps/bootstrap_hscv: rscripts/bootstrap_hscv.R
	$(call R,bootstrap_hscv.R)
	$(call MAIL,bootstrap_hscv.R)
	touch pbetti/reps/bootstrap_hscv
pbetti/reps/bootstrap_adapt: rscripts/bootstrap_adapt.R
	$(call R,bootstrap_adapt.R)
	$(call MAIL,bootstrap_adapt.R)
	touch pbetti/reps/bootstrap_adapt
pbetti/reps/bootstrap_silv: rscripts/bootstrap_silv.R
	$(call R,bootstrap_silv.R)
	$(call MAIL,bootstrap_silv.R)
	touch pbetti/reps/bootstrap_silv

pbetti/coverage_hpi.csv: pbetti/pbetti_mean.csv pbetti/reps/bootstrap_hpi rscripts/coverage_hpi.R
	$(call R,coverage_hpi.R)
pbetti/coverage_hlscv.csv: pbetti/pbetti_mean.csv pbetti/reps/bootstrap_hlscv rscripts/coverage_hlscv.R
	$(call R,coverage_hlscv.R)
pbetti/coverage_hscv.csv: pbetti/pbetti_mean.csv pbetti/reps/bootstrap_hscv rscripts/coverage_hscv.R
	$(call R,coverage_hscv.R)
pbetti/coverage_adapt.csv: pbetti/pbetti_mean.csv pbetti/reps/bootstrap_adapt rscripts/coverage_adapt.R
	$(call R,coverage_adapt.R)
pbetti/coverage_silv.csv: pbetti/pbetti_mean.csv pbetti/reps/bootstrap_silv rscripts/coverage_silv.R
	$(call R,coverage_silv.R)

plots/plot_bootstrap_comp.pdf: rscripts/plots.R
	$(call R,plots.R)

galaxy/galaxy: rscripts/galaxy.R
	$(call R,galaxy.R)
	$(call MAIL,galaxy.R)
	touch galaxy/galaxy
