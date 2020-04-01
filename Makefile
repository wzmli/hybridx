### Lunchbox main engine

current: target
-include target.mk

##################################################################

Sources = Makefile README.md

## ADVANCED
## The recommended way to change these directories is with a local makefile. 
## The recommended way to make a local makefile is to push a file with a specific name, and then manually link local.mk to your specific local makefile
## local.mk does not exist out of the box; this should not cause problems
dirroot = ./
code = $(dirroot)/code
data = $(dirroot)/data

-include local.mk
ms = makestuff

# This is the local configuration we happen to be using right now
# Sources += dev.mk
dev:
	/bin/ln -fs dev.mk local.mk

# Sources += todo.md

Sources += $(wildcard *.R)

# See name.R for name parsing

sim.%.Rout: simfuns.Rout parameters.CBB.Rout name.R simulate.CBB.R
	$(run-R)

plot.%.Rout: sim.%.Rout parameters.CBB.Rout plot.R
	$(run-R)

## sim.dis.1.bb.p.1.jags.Rout: simulate.CBB.R
## plot.dis.1.bb.p.1.jags.Rout: plot.R

templates.hyb.1.bb.p.1.jags.Rout:
templates.%.Rout: name.R parameters.CBB.R process_funs.R observations_funs.R bugstemplate_funs.R bugstemplate.R process_stan.R observation_stan.R stantemplate.R 	
	$(run-R)

fit.hyb.1.bb.nb.1.jags.Rout:
fit.dis.1.bb.bb.1.nim.Rout:
fit.hyb.1.bb.nb.1.nim.Rout:
fit.hyb.1.bb.nb.1.stan.Rout:

fit.hyb.1.nb.nb.1.jags.Rout:

fit.%.Rout: name.R sim.%.Rout templates.%.Rout fit.R
	$(run-R)


Sources += source.R

source.Rout: source.R


# Sources += collect_results_stan.R
collect_results_stan.Rout: parameters.CBB.Rout collect_results_stan.R
	$(run-R)



collect_pars_%_jags.Rout: parameters.CBB.Rout collect_pars_jags.R
	$(run-R)

collect_pars_%_nim.Rout: parameters.CBB.Rout collect_pars_nim.R
	$(run-R)

collect_pars_%_stan.Rout: parameters.CBB.Rout collect_pars_stan.R
	$(run-R)
collect_pars_hyb.1.bb.nb_jags.Rout:


## Forecast

forecast_%_jags.Rout: parameters.CBB.Rout simfuns.R forecast_jags.R
	$(run-R)

forecast_%_nim.Rout: parameters.CBB.Rout simfuns.R forecast_nim.R
	$(run-R)

forecast_%_stan.Rout: parameters.CBB.Rout simfuns.R forecast_stan.R
	$(run-R)

## Mean Generation Intervals

gen_%_jags.Rout: parameters.CBB.Rout simfuns.R gen_jags.R
	$(run-R)

gen_%_nim.Rout: parameters.CBB.Rout simfuns.R gen_nim.R
	$(run-R)

gen_%_stan.Rout: parameters.CBB.Rout simfuns.R gen_stan.R
	$(run-R)

### Pool results

pool_%.Rout: pool.R
	$(run-R)

#####plots

forecast_plot.Rout: ./jags_dir/results/fcjags.RDS ./nimble_dir/results/fcnim.RDS ./stan_dir/results/fcstan.RDS name.R forecast_plot.R
	$(run-R)

gen_plot.Rout: ./jags_dir/results/genjags.RDS ./nimble_dir/results/gennim.RDS ./stan_dir/results/genstan.RDS name.R gen_plot.R
	$(run-R)


parameter_plot.Rout: ./jags_dir/results/parsjags.RDS ./nimble_dir/results/parsnim.RDS ./stan_dir/results/parsstan.RDS name.R parameter_plot.R
	$(run-R)



####forecast obs plot

forecastplot_%_jags.Rout: parameters.CBB.Rout simfuns.R forecastplot_jags.R
	$(run-R)

forecastplot_%_nim.Rout: parameters.CBB.Rout simfuns.R forecastplot_nim.R
	$(run-R)

forecastplot_%_stan.Rout: parameters.CBB.Rout simfuns.R forecastplot_stan.R
	$(run-R)



simplots.Rout: simplots.R
	$(run-R)

ggsimplots.Rout: simplots.Rout ggsimplots.R
	$(run-R)

cleanall:
	rm -f *.nimble.R *.buggen *.wrapR.r *.Rout *.nimcode *.stan *.init.R *.data.R *.Rlog *.wrapR.rout .sim* .template* .fit* *.jags *.nim jags_dir/data/*.Rds jags_dir/templates/templates* nimble_dir/templates/*.nimcode nimble_dir/data/*.Rds stan_dir/templates/*.stan stan_dir/data/*.Rds

clean: 
	rm -f *.wrapR.r *.Rout *.Rlog *.wrapR.rout .sim.* .templates.* .fit.*

new: clean
	rm -f *.Rds

run_dis:
	bash run_all_b


kill:
	kill $(jobs -p)

######################################################################

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff
Makefile: makestuff/Makefile
makestuff/Makefile:
	git clone $(msrepo)/makestuff
	ls $@

-include makestuff/os.mk

## -include makestuff/wrapR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
