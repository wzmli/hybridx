library(methods)
library(nimble)
library(R2jags)
library(rstan)

set.seed(seed)

## This is the part we want to sub data in instead of simulated data
dat <- sim
# dat <- head(sim,numobs)
# if(is.null(dat)){dat <- head(sim,numobs)}
# if(plat %in% c("jags","nim")){
#   NAmat <- dat
#   NAmat[!is.numeric(NAmat)] <- NA
#   dat <- rbind(dat,head(NAmat,forecast))
#   numobs <- nrow(dat)
# }

myRound <- nimbleFunction(
  run=function(x=double()){
    return(round(x))
    returnType(double())
  }
)

nimbleOptions(verifyConjugatePosteriors=TRUE)
nimdata <- lme4:::namedList(obs=dat$Iobs[(lag+1):(lag+numobs)])

initlist <- lme4:::namedList(R0=Rshape/Rrate,kerShape,kerPos)
mult = 1:mchains
niminits <- lapply(mult, function(m){
  initver <- function(x){
    if(x==2){return(lme4:::namedList(effrep,effrepprop))}
    return(lme4:::namedList(effprop,repprop))
  }
  inittype <- function(x,y){
    if(x=="hyb"){return(lme4:::namedList(Ihat=c(rep(1,lag),dat$Iobs[(lag+1):(lag+numobs)]+1 + m)))}
    if(y=="jags"){return(lme4:::namedList(I = c(rep(1,lag),
                                                (dat$Iobs[(lag+1):(numobs)]+1),
                                                (dat$Iobs[(numobs+1):(lag+numobs)]+1 + m))))}
    return(lme4:::namedList(I = c(rep(1,lag),
                                  (dat$Iobs[(lag+1):(numobs)]+1),
                                  (dat$Iobs[(numobs+1):(lag+numobs)]+1 + m))))
  }
  initproc <- function(x,y){
    if(x == "bb"){return(lme4:::namedList(pDis))}
    if(x == "nb"){return(lme4:::namedList(pDis))}
    if((x == "bb") & (y=="dis")){return(lme4:::namedList(pDis,phat=rep(repprop,numobs)))}
    return(NULL)
  }
  initobs <- function(x){
    if(x=="bb"){return(lme4:::namedList(repDis,reporting=rep(repprop,numobs)))}
    if(x=="nb"){return(lme4:::namedList(obsMean=dat$Iobs[(lag+1):(lag+numobs)]+1,repDis))}
    return(NULL)
  }
  return(c(initlist,initver(version),inittype(type,plat),initproc(x=process,y=type),initobs(observation))
  )})

conlist <- lme4:::namedList(N,numobs,i0,Rshape,Rrate
                            ,lag,kPa,kPb,ksshape,ksrate)
conver <- function(x){
  if(x==2){return(lme4:::namedList(effrepa,effrepb,effreppropa,effreppropb))}
  return(lme4:::namedList(effa,effb,repa,repb))
}

contype <- function(x){
  if(x=="hyb"){return(lme4:::namedList(eps))}
  return(NULL)
}
conproc <- function(x){
  if(x=="bb"){return(lme4:::namedList(pDshape,pDrate))}
  if(x=="nb"){return(lme4:::namedList(pDshape,pDrate,epsp))}
  return(NULL)
}
conobs <- function(x){
  if(x=="bb"){return(lme4:::namedList(repDshape,repDrate))}
  if(x=="nb"){return(lme4:::namedList(repDshape,repDrate,epso))}
  return(NULL)
}
nimcon <- c(conlist,conver(version),contype(type),conproc(process),conobs(observation))


paramsfun <- function(vv,tt,pp,proc,obs){
  params <- c("R0","effprop","repprop","kerShape","kerPos")
  if(version==2){
    params <- c(params,"effrep","effrepprop")
  }
  if(type=="dis"){
    params <-c(params,"I")
  }
  if(type=="hyb"){
    params <- c(params,"Ihat")
  }
  if(pp %in% c("jags","nim")){
    params <- c(params,"obs","ker")
  }
  if(proc %in% c("bb","nb")){
    params <- c(params,"pDis")
  }
  if(obs %in% c("bb","nb")){
    params <- c(params,"repDis")
  }
  return(params)
}
  
params <- paramsfun(vv=version,tt=type,pp=plat,proc=process,obs=observation)


source(paste("./nimble_dir/templates/templates",type,version,process,observation,seed,iterations,plat,"nimcode",sep="."))
mcmcs <- c("jags"
           ,"nimble"
           ,"nimble_slice") 

if(plat == "nim"){
  datadir <- "./nimble_dir/data/"
  nimmod <- nimbleModel(code=nimcode,constants=nimcon,data=nimdata,inits=niminits)
  Cnimmod <- compileNimble(nimmod)
  configMOD <- configureMCMC(nimmod)
  configMOD$addMonitors(params)
  Bmcmc <- buildMCMC(configMOD)
  Cmcmc <- compileNimble(Bmcmc,project = nimmod)
  MCMCtime <- system.time(FitModel <-runMCMC(Cmcmc,niter=iterations,nchains=length(niminits),inits=niminits,returnCodaMCMC = TRUE))

  summary(FitModel)
  }

if(plat == "jags"){
  datadir <- "./jags_dir/data/"
  modfile <- paste("./jags_dir/templates/templates",type,version,process,observation,seed,iterations,plat,sep=".")
  MCMCtime <- system.time(FitModel <- jags(data=c(nimdata,nimcon)
                   , inits=niminits
                   , param = params
                   , model.file = modfile
                   , n.iter = iterations
                   , n.chains = length(niminits)
  ))
  FitModel <- as.mcmc(FitModel)
  summary(FitModel)
}


if(plat == "stan"){
  datadir <- "./stan_dir/data/"
  modfile <- paste("./stan_dir/templates/templates",type,version,process,observation,seed,iterations,plat,sep=".")
  FitModel <- stan(file=modfile
                   , data=c(nimdata,nimcon)
                   , init=niminits
                   , pars=params
                   , iter=iterations
                   , chains=length(niminits)
  )
  print(FitModel)
  MCMCtime <- get_elapsed_time(FitModel)
  FitModel <- As.mcmc.list(FitModel)
}

mcmc_results <- list(FitModel,MCMCtime,dat)
saveRDS(mcmc_results,file=paste(datadir,paste(type,version,process,observation,seed,iterations,plat,"Rds",sep="."),sep=""))

# rdnosave()
