### Running lunchbox engine without make

fitmod <- function(rtargetname){
  ## Naming step
  
  targetname <-unlist(strsplit(rtargetname,"[.]"))
  
  type <- targetname[2]
  version <- as.numeric(targetname[3])
  process <- targetname[4]
  observation <- targetname[5]
  seed <- as.numeric(targetname[6])
  iterations <- as.numeric(targetname[7])
  plat <- targetname[8]
	
	## Simulate data step

	source("simfuns.R")
	source("parameters.CBB.R")
  system.time(sim <- simm(N=N
  , lag=lag
  , betasize0=betaSize
  , effprop0=effprop
  , Rshape0=Rshape, Rrate0=Rrate
  , i0=i0
  , repprop0=repprop
  , ksshape0=ksshape , ksrate0=ksrate
  , pDshape0=pDshape , pDrate0=pDrate
  , kerPos0=kerPos
  , repDshape0=repDshape , repDrate0=repDrate
  , numobs=(numobs+forecast)
  , seed=seed
  )
  )

	## Creating template

	source("process_funs.R")
	source("observations_funs.R")
	source("bugstemplate_funs.R")
  
  process_code <- processfun(ty=type,proc=process)
  observation_code <- obsfun(ty=type,obsp=observation)
  
  cat(nimstart[1]
      , priorfun(ver=version,ty=type,pl=plat)
      , process_code[1]
      , observation_code[1]
      , iterloop[1]
      , process_code[2]
      , process_code[3]
      , observation_code[2]
      , iterloop[2]
      , nimstart[2]
      , file=paste("./nimble_dir/templates/", 
                   paste(rtargetname,".nimcode",sep=""),sep="")
  )
  
  cat("model{"
      , priorfun(ver=version,ty=type)
      , process_code[1]
      , observation_code[1]
      , iterloop[1]
      , process_code[2]
      , process_code[3]
      , observation_code[2]
      , iterloop[2]
      , "}",file=paste("./jags_dir/templates/",rtargetname,sep=""))
  
	source("process_stan.R")
	source("observation_stan.R")
	source("stantemplate.R")

	## fit

	source("fit.R")
}

fitmod("fit.hyb.2.bb.nb.1.1000.nim")


