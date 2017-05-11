### Running lunchbox engine without make

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

fitmod("fit.hyb.2.bb.nb.1.1000.nim")


