### Lunchbox main engine

current: target

target pngtarget pdftarget vtarget acrtarget: fit.dis.1.bb.bb.1.jags.Rout 

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
Sources += dev.mk
dev:
	/bin/ln -fs dev.mk local.mk

Sources += todo.md

Sources += $(wildcard *.R)

# See name.R for name parsing

sim.dis.1.bb.p.1.nim.Rout:

sim.%.Rout: simfuns.R parameters.CBB.R name.R simulate.CBB.R
	$(run-R)

templates.hyb.1.bb.p.1.jags.Rout:
templates.%.Rout: name.R parameters.CBB.R process_funs.R observations_funs.R bugstemplate_funs.R bugstemplate.R process_stan.R observation_stan.R stantemplate.R 	
	$(run-R)

fit.dis.1.bb.bb.1.jags.Rout:


fit.%.Rout: name.R sim.%.Rout templates.%.Rout fit.R
	$(run-R)


Sources += source.R

source.Rout: source.R


# Sources += collect_results_stan.R
collect_results_stan.Rout: parameters.CBB.Rout collect_results_stan.R
	$(run-R)

%.plot.Rout: parameters.CBB.R simfuns.Rout ./temp_results/collect.results.%.2000.RDS plot.R
	$(run-R)

forecast.plot.Rout: jagsFC.RDS nimFC2.RDS stanFC.RDS forecast.plot.R
	$(run-R)

%.Rds: fit.%.Rout ;

plot.%.Rout: %.Rds jagsplot.R
	$(run-R)

forecast.stan.%.Rout: parameters.CBB.R simfuns.R forecast_stan.R
	$(run-R)

forecast.nim.%.Rout: parameters.CBB.R simfuns.R forecast_nim.R
	$(run-R)

forecast.jags.%.Rout: parameters.CBB.R simfuns.R forecast_jags.R
	$(run-R)

gen.stan.%.Rout: gen_stan.R
	$(run-R)

gen.nim.%.Rout: gen_nim.R
	$(run-R)

gen.nimh.%.Rout: gen_nimh.R
	$(run-R)

gen.jags.%.Rout: gen_jags.R
	$(run-R)

collect_stan_fc.Rout: collect_stan_fc.R
	$(run-R)

parameter.plot.Rout: jagsPAR.RDS nimPARh.RDS stanPAR.RDS parameter.plot.R
	$(run-R)


#####plots

forecast_plot.Rout: forecast_plot.R
%_plot.Rout: %_results.RDS %_plot.R
	$(run-R)

gen.plot.Rout: jagsGEN.RDS nimGEN2.RDS stanGEN.RDS gen.plot.R
	$(run-R)

all.plot.Rout: forecast.plot.Rout parameter.plot.Rout gen.plot.Rout all.plot.R
	$(run-R)

#####


pooljags.Rout: pooljags.R

bbplot.Rout: jagsPAR.RDS nimPARd.RDS nimPARh.RDS stanPAR.RDS parameter.plot.R
	$(run-R)

testing: run_all
	bash run_all

clean:
	rm -f *.nimble.R *.buggen *.wrapR.r *.Rout *.nimcode *.stan *.init.R *.data.R *.Rlog *.wrapR.rout .sim* .template* .fit* *.jags *.nim jags_dir/data/*.Rds jags_dir/templates/templates* nimble_dir/templates/*.nimcode nimble_dir/data/*.Rds stan_dir/templates/*.stan stan_dir/data/*.Rds

new: clean
	rm -f *.Rds

run_dis:
	bash run_all_b

#############

### Makestuff

Sources += $(wildcard $(ms)/*.mk)
Sources += $(wildcard $(ms)/RR/*.*)
Sources += $(wildcard $(ms)/wrapR/*.*)

-include $(ms)/os.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
