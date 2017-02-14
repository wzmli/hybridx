### Lunchbox main engine

current: target

target pngtarget pdftarget vtarget acrtarget: fit.hyb.2.bb.nb.1.1000.nim.Rout 

##################################################################

Sources += Makefile stuff.mk LICENSE.md
include stuff.mk
-include $(ms)/git.def

Sources += todo.md

Sources += $(wildcard *.R)

# See name.R for name parsing

sim.dis.1.bb.p.1.4000.nim.Rout:

sim.%.Rout: simfuns.R parameters.CBB.R name.R simulate.CBB.R
	$(run-R)

templates.hyb.1.bb.p.1.1000.jags.Rout:
templates.%.Rout: name.R parameters.CBB.R process.R observations.R bugstemplate.R process_stan.R observation_stan.R stantemplate.R 	
	$(run-R)

fit.hyb.2.bb.nb.1.1000.nim.Rout:
fit.%.Rout: name.R sim.%.Rout templates.%.Rout fit.R
	$(run-R)


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
	rm -f *.nimble.R *.buggen *.wrapR.r *.Rout *.nimcode *.stan *.init.R *.data.R *.Rlog *.wrapR.rout .sim* .template* .fit* *.jags *.nim

new: clean
	rm -f *.Rds

run_dis:
	bash run_all_b

#############

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/linux.mk
-include $(ms)/wrapR.mk
-include rmd.mk
