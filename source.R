### Running engine without make

fitmod <- function(name){
  ## Naming step
  
  rtargetname <- name
  source("name.R",local = TRUE)
  
	## Simulate data step

	source("simfuns.R")
	source("parameters.CBB.R")
  source("simulate.CBB.R",local=TRUE)

	## Creating template

	source("process_funs.R")
	source("observations_funs.R")
	source("bugstemplate_funs.R")
  source("bugstemplate.R",local=TRUE)
	source("process_stan.R",local=TRUE)
	source("observation_stan.R",local=TRUE)
	source("stantemplate.R",local=TRUE)

	## fit

	source("fit.R",local=TRUE)
}

## examples of how to run this
#fitmod("fit.dis.2.nb.nb.1.jags")
#fitmod("fit.dis.1.bb.p.1.nim")
#fitmod("fit.hyb.1.b.nb.1.stan")



