library(coda)

targetname <-unlist(strsplit(rtargetname,"[_]"))

parlist <- c("R0","effprop","repprop","pDis","repDis","kerShape","kerPos")
qtilesnames <- c("q2.5","q5","q10","q25","q50","q75","q90","q95","q97.5")

qlist <- c(0.025,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.975)


stanfilenames <- list.files(path="./stan_dir/data/",pattern=targetname[3])


getparstan <- function(n){
  stanobj <- readRDS(paste("./stan_dir/data/",n,sep=""))
  stanmod <- stanobj[[1]]
  dat <- stanobj[[3]]
  parlist2 <- parlist[parlist %in% colnames(stanmod[[1]])]
  Rhatcalc <- gelman.diag(stanmod[,parlist2])
  
  real <- c(dat$R0,dat$effprop,dat$repprop,dat$pDis,dat$repDis,dat$kerShape,dat$kerPos)
  real2 <- real[parlist %in% colnames(stanmod[[1]])]
  timeobj <- stanobj[[2]]
  neff <- effectiveSize(stanmod[,parlist2])
  time <- timeobj[1]
  name <- unlist(strsplit(n,"[.]"))
  stansum <- summary(stanmod,quantiles = qlist)
  parmat <- data.frame(stansum$quantiles[parlist2,])
  colnames(parmat) <- c("q2.5","q5","q10","q25","q50","q75","q90","q95","q97.5")
  tempdat <- data.frame(type = name[1]
                        , version=name[2]
                        , process=name[3]
                        , observation=name[4]
                        , seed = name[5]
                        , platform = name[6]
                        , parameters = parlist2
                        , real = real2
                        , Rhat = Rhatcalc$psrf[,1]
                        , ESS = neff
                        , time = time
                        , parmat
  )
  rownames(tempdat) <- NULL
  return(tempdat)
}

t2 <- system.time(stanpar <- lapply(stanfilenames,getparstan))

print(t2)

print(stanpar[[1]])
stanlist <- list(stanpar)
saveRDS(stanlist,file=paste("./stan_dir/results/pars_",targetname[3],".RDS",sep=""))
