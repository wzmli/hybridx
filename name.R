targetname <-unlist(strsplit(rtargetname,"[.]"))

type <- targetname[2]   ## hybrid or discrete 
version <- as.numeric(targetname[3])  ## version 1 standard effective prop and reporting prop, version 2 is multiple scale decorrelation (see section 2.2.2 in the paper)
process <- targetname[4]	## transmission process distribution
observation <- targetname[5]	## reporting process distribution
seed <- as.numeric(targetname[6])
plat <- targetname[7]	## jags, nim=nimble, stan

templatename <- paste("templates",type,version,process,observation,seed,plat,sep=".")
