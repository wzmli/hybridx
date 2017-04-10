priorfun <- function(ver=1,ty="dis",pl="jags"){
  priors <- c("
  R0 ~ dgamma(Rshape,Rrate)
  kerShape ~ dgamma(ksshape,ksrate)
  kerPos ~ dbeta(kPa,kPb)"
  ,"
  for(t in 1:lag){
  ","
    ker[t] <- exp((kerShape-1)*log(t) - (t)/(kerPos*lag))
  }")
  version_prior <- "
  effprop ~ dbeta(effa,effb)
  repprop ~ dbeta(repa,repb)
  "
  if(ver==2){
    version_prior <- "
  effrep ~ dbeta(effrepa,effrepb)
  effrepprop ~ dbeta(effreppropa,effreppropb)
  effprop <- exp((1-effrepprop)*log(effrep))
  repprop <- exp((effrepprop)*log(effrep))
    "
  }
  N0 <- c("
  N0 <- round(effprop*N)")
  if(pl=="nim"){
  N0 <- c("
  N0 <- myRound(effprop*N)")}
  I <- c("
  I[t] ~ dbin(1,i0)")
  S <- "
  S[t] <- N0 - i0"
  pSI <- "
  pSI[1] <- 1 - exp(-sum(I[1:lag]*(ker[1:lag]/sum(ker[1:lag])))*(R0/N0))"
  if(ty=="hyb"){
    N0 <- "
  N0 <- effprop*N"
    I <- "
    Ihat[t] ~ dgamma(i0,1/repprop)"
    S <- "
    S[t] <- N0 - Ihat[t]/repprop"
    pSI <- "
  pSI[1] <- 1 - exp(-sum((Ihat[1:lag]/repprop)*(ker[1:lag]/sum(ker[1:lag])))*(R0/(N0)))" 
  }
  return(c(priors[1],N0,version_prior,priors[2],I,S,priors[3],pSI))
}

iterloop <- c("
  for(t in 1:numobs){"
  ,"
  }")

nimstart <- c("
nimcode <- nimbleCode({
  ","
  }
)")



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
