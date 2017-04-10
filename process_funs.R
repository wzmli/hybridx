process_code <- NULL

processfun <- function(ty="dis",proc="b"){
  outterloop <- ""
  innerI <-"
    I[lag+t] ~ dbin(pSI[t],S[lag+t-1])"
  innerSPSI <- "
    S[lag+t] <- max(S[lag+t-1] - I[lag+t],1)
    pSI[1+t] <- 1 - exp(-sum(I[(t+1):(lag+t)]*(ker[1:lag]/sum(ker[1:lag])))*(R0/N0))
  "
  if(proc=="bb"){
    outterloop <- "
  pDis ~ dgamma(pDshape,pDrate)"
    innerI <-"
    phat[t] ~ dbeta(pDis/(1-pSI[t]),pDis/pSI[t])
    I[lag+t] ~ dbin(phat[t],S[lag+t-1])"
  }
  if(proc=="p"){
    innerI <- "
    I[lag+t] ~ dpois(pSI[t]*S[lag+t-1])"
  }
  if(proc=="nb"){
    outterloop <- "
  pDis ~ dunif(0,100)"
    innerI <- "
    Imean[t] ~ dgamma(pDis,pDis/(S[lag+t-1]*pSI[t]+epsp))
    I[lag+t] ~ dpois(Imean[t])"
  }
  if(ty=="hyb"){ ######################################################################################################
    innerI <-"
    SIGrate[t] <- 1/(1-pSI[t]+eps)
    SIGshape[t] <- pSI[t]*SIGrate[t]*(S[lag+t-1])
    Ihat[lag+t] ~ dgamma(SIGshape[t],SIGrate[t]/repprop)"
    innerSPSI <- "
    S[lag+t] <- max(S[lag+t-1] - Ihat[lag+t]/repprop,eps)
    pSI[1+t] <- 1 - exp(-sum((Ihat[(t+1):(lag+t)]/repprop)*(ker[1:lag]/sum(ker[1:lag])))*(R0/(N0)))"
    if(proc=="bb"){
      innerI <- "
    SIGrate[t] <- (pDis/(pSI[t]*(1-pSI[t]))+1)/((1-pSI[t]+eps)*(pDis/(pSI[t]*(1-pSI[t]))+S[lag+t-1]))
    SIGshape[t] <- pSI[t]*SIGrate[t]*S[lag+t-1]
    Ihat[lag+t] ~ dgamma(SIGshape[t],SIGrate[t]/repprop)"
    }
    if(proc=="p"){
      innerI <- "
    SIGrate[t] <- 1
    SIGshape[t] <- pSI[t]*S[lag+t-1]
    Ihat[lag+t] ~ dgamma(SIGshape[t],SIGrate[t]/repprop)"
    }
    if(proc=="nb"){
      innerI <- "
    SIGrate[t] <- pDis/(pDis+pSI[t]*S[lag+t-1])
    SIGshape[t] <- pSI[t]*S[lag+t-1]*SIGrate[t]
    Ihat[lag+t] ~ dgamma(SIGshape[t],SIGrate[t]/repprop)"
    }
  }
  code <- c(outterloop,innerI,innerSPSI)
  return(code)
}



