library(R2jags)
library(coda)

parlist <- c("R0","effprop","repprop","pDis","repDis","kerShape","kerPos")

qtilesnames <- c("q2.5","q5","q10","q25","q50","q75","q90","q95","q97.5")

qlist <- c(0.025,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.975)


jagsfilenames <- list.files(path="./jags_dir/data/",pattern="jags.Rds")


getparjags <- function(n){
  jagsobj <- readRDS(paste("./jags_dir/data/",n,sep=""))
  # jagsmodraw <- jagsobj[[1]]
  # ndim <- nrow(jagsmodraw[[1]])
  # jagsthin <- lapply(jagsmodraw,function(x){mcmc(x,start=floor(ndim/2),end=ndim,thin=1)})
  # jagsmod <- as.mcmc.list(jagsthin)
  jagsmod <- jagsobj[[1]]
  dat <- jagsobj[[3]]
  parlist2 <- parlist[parlist %in% colnames(jagsmod[[1]])]
  Rhatcalc <- gelman.diag(jagsmod[,parlist2])
  real <- c(dat$R0,dat$effprop,dat$repprop,dat$pDis,dat$repDis,dat$kerShape,dat$kerPos)
  real2 <- real[parlist %in% colnames(jagsmod[[1]])]
  timeobj <- jagsobj[[2]]
  neff <- effectiveSize(jagsmod[,parlist2])
  time <- timeobj[1]
  name <- unlist(strsplit(n,"[.]"))
  jagssum <- summary(jagsmod,quantiles = qlist)
  parmat <- data.frame(jagssum$quantiles[parlist2,])
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

t2 <- system.time(jagspar <- lapply(jagsfilenames,getparjags))

print(t2)

print(jagspar[[1]])
jagslist <- list(jagspar)
saveRDS(jagslist,file="./jags_dir/results/jagsPAR.RDS")
