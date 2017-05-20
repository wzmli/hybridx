### Lunchbox main engine

current: target

target pngtarget pdftarget vtarget acrtarget: forecast_hyb.1.bb.nb.1.jags_jags.Rout 

##################################################################

Sources = Makefile .gitignore README.md LICENSE

## ADVANCED
## The recommended way to change these directories is with a local makefile. 
## The recommended way to make a local makefile is to push a file with a specific name, and then manually link local.mk to your specific local makefile
## local.mk does not exist out of the box; this should not cause problems
dirroot = ./
code = $(dirroot)/code
data = $(dirroot)/data

-include local.mk
ms = $(code)/makestuff

# This is the local configuration we happen to be using right now
# Sources += dev.mk
dev:
	/bin/ln -fs dev.mk local.mk

# Sources += todo.md

Sources += $(wildcard *.R)

# See name.R for name parsing

sim.dis.1.bb.p.1.nim.Rout:

sim.%.Rout: simfuns.R parameters.CBB.R name.R simulate.CBB.R
	$(run-R)

templates.hyb.1.bb.p.1.jags.Rout:
templates.%.Rout: name.R parameters.CBB.R process_funs.R observations_funs.R bugstemplate_funs.R bugstemplate.R process_stan.R observation_stan.R stantemplate.R 	
	$(run-R)

fit.hyb.1.bb.nb.1.jags.Rout:
fit.dis.1.bb.bb.1.nim.Rout:
fit.hyb.1.bb.nb.1.nim.Rout:
fit.hyb.1.bb.nb.1.stan.Rout:

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

forecast_hyb.1.bb.nb.1.jags_jags.Rout:

### Pool results

pool_%.Rout: pool.R
	$(run-R)

#####plots


parameter_plot.Rout: ./jags_dir/results/parsjags.RDS ./nimble_dir/results/parsnim.RDS ./stan_dir/results/parsstan.RDS name.R parameter_plot.R
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

#############

### Makestuff

Sources += $(wildcard $(ms)/*.mk)
Sources += $(wildcard $(ms)/RR/*.*)
Sources += $(wildcard $(ms)/wrapR/*.*)

-include $(ms)/os.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
