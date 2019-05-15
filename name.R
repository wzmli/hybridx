targetname <-unlist(strsplit(rtargetname,"[.]"))

type <- targetname[2]
version <- as.numeric(targetname[3])
process <- targetname[4]
observation <- targetname[5]
seed <- as.numeric(targetname[6])
plat <- targetname[7]

templatename <- paste("templates",type,version,process,observation,seed,plat,sep=".")
