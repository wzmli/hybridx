
library(nimble)
library(R2jags)
library(coda)

parlist <- c("R0","effprop","repprop","pDis","repDis","kerShape","kerPos")

qtilesnames <- c("q2.5","q5","q10","q25","q50","q75","q90","q95","q97.5")

qlist <- c(0.025,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.975)


nimfilenames <- list.files(path="./nimble_dir/data/",pattern="nim.Rds")


getparnim <- function(n){
  nimobj <- readRDS(paste("./nimble_dir/data/",n,sep=""))
  # nimmodraw <- nimobj[[1]]
  # ndim <- nrow(nimmodraw[[1]])
  # nimthin <- lapply(nimmodraw,function(x){mcmc(x,start=25001,end=50000,thin=1)})
  # nimmod <- as.mcmc.list(nimthin)
  nimmod <- nimobj[[1]]
  dat <- nimobj[[3]]
  parlist2 <- parlist[parlist %in% colnames(nimmod[[1]])]
  Rhatcalc <- gelman.diag(nimmod[,parlist2])
  
  real <- c(dat$R0,dat$effprop,dat$repprop,dat$pDis,dat$repDis,dat$kerShape,dat$kerPos)
  real2 <- real[parlist %in% colnames(nimmod[[1]])]
  timeobj <- nimobj[[2]]
  neff <- effectiveSize(nimmod[,parlist2])
  time <- timeobj[1]
  name <- unlist(strsplit(n,"[.]"))
  nimsum <- summary(nimmod,quantiles = qlist)
  parmat <- data.frame(nimsum$quantiles[parlist2,])
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

t2 <- system.time(nimpar <- lapply(nimfilenames,getparnim))

print(t2)

print(nimpar[[1]])
nimlist <- list(nimpar)
saveRDS(nimlist,file="./nimble_dir/results/nimPAR.RDS")
