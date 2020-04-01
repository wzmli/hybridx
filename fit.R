library(methods)
library(nimble)
library(R2jags)
library(rstan)

set.seed(seed)

## This is the part we want to sub data in instead of simulated data
dat <- sim

print(dat)

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
    params <- c(params,"obs","ker","tempMGI","MGI")
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


# mcmcs <- c("jags"
#            ,"nimble"
#            ,"nimble_slice") 

if(plat == "nim"){

source(paste("./nimble_dir/templates/fit",type,version,process,observation,seed,plat,sep="."))
  datadir <- "./nimble_dir/data/"
  nimmod <- nimbleModel(code=nimcode,constants=nimcon,data=nimdata,inits=niminits[[1]])
  Cnimmod <- compileNimble(nimmod)
  configMOD <- configureMCMC(nimmod)
  configMOD$addMonitors(params)
  Bmcmc <- buildMCMC(configMOD)
  Cmcmc <- compileNimble(Bmcmc,project = nimmod)
  miter <- miter*2
  while(miter < 1000000){
  MCMCtime <- system.time(FitModel <-runMCMC(Cmcmc,niter=miter,nburnin = floor(miter/2),nchains=length(niminits),inits=niminits
                                             ,samples = TRUE))
    Rhatcalc <- gelman.diag(FitModel[,c("effprop","R0","repprop")])$psrf[,1]
    neff <- effectiveSize(FitModel)[c("effprop","R0","repprop")]
    miter <- miter*2
    print(Rhatcalc)
    if(all(Rhatcalc<1.1,neff>400)){
      miter <- 1000*1000 + 1
    }
  }
  sampling_time <- MCMCtime
  }

if(plat == "jags"){
  datadir <- "./jags_dir/data/"
  modfile <- paste("./jags_dir/templates/fit",type,version,process,observation,seed,plat,sep=".")
  while(miter < 1000000){
  system.time(jagsmod <- jags.model(data=c(nimdata,nimcon)
                        , inits=niminits
                        , file = modfile
                        , n.adapt = 2000
                        , n.chains = length(niminits)
  )
  )
  
  MCMCtime <- system.time(
    FitModel <- coda.samples(model = jagsmod
                            , n.iter = miter
                            , n.thin = mthin
                            , variable.names = params
    )
  )
  miter <- miter*2
  Rhatcalc <- gelman.diag(FitModel[,c("effprop","R0","repprop")])$psrf[,1]
  sampling_time <- MCMCtime
  neff <- effectiveSize(FitModel)[c("effprop","R0","repprop")]
  if(all(Rhatcalc<1.1,neff>400)){miter <- 1000*1000 + 1000} 
  }
}

if(plat == "stan"){
  datadir <- "./stan_dir/data/"
  modfile <- paste("./stan_dir/templates/templates",type,version,process,observation,seed,plat,sep=".")
  buildstan <- stan_model(file=modfile
#                    , data=c(nimdata,nimcon)
#                    , init=niminits
#                    , pars=params
#                    , chains=length(niminits)
  )
  while(miter < 1000000){
  FitModel <- sampling(buildstan,data=c(nimdata,nimcon),init=niminits,pars=params,chains=length(niminits),iter=miter)
  MCMCtime <- get_elapsed_time(FitModel)
  sampling_time <- sum(MCMCtime[,2])
  FitModel <- As.mcmc.list(FitModel)
  Rhatcalc <- gelman.diag(FitModel[,c("effprop","R0","repprop")])$psrf[,1]
  neff <- effectiveSize(FitModel)[c("effprop","R0","repprop")]
  miter <- miter*2
  if(all(Rhatcalc<1.1,neff>400)){
    miter <- 1000*1000 + 1000
  }
  }
}

print(sampling_time)
mcmc_results <- list(FitModel,sampling_time,sim)

print(summary(FitModel))
print(Rhatcalc)
if(all(Rhatcalc<1.1,neff>400)){
saveRDS(mcmc_results,file=paste(datadir,paste(type,version,process,observation,seed,plat,"Rds",sep="."),sep=""))
}
# rdnosave()
