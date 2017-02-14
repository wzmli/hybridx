process_stancode <- NULL

process_stanfun <- function(proc="b"){
  outterloop <- ""
  innerI <-"
  SIGrate[t] = 1/(1-pSI[t]);
  SIGshape[t] = pSI[t]*SIGrate[t]*(S[lag+t-1]);
  Ihat[lag+t] ~ gamma(SIGshape[t],SIGrate[t]/repprop);"
  innerSPSI <- "
  S[lag+t] = fmax(S[lag+t-1] - Ihat[lag+t]/repprop,eps);
  pSI[t+1] = 1 - exp(-(R0/(N0*repprop))*dot_product(Ihat[(t+1):(lag+t)],kerr[1:lag]));
  "
  if(proc=="bb"){
    outterloop <- "
  pDis ~ gamma(pDshape,pDrate);"
    innerI <- "
  SIGrate[t] = (pDis/(pSI[t]*(1-pSI[t]))+1)/((1-pSI[t]+epsp)*(pDis/(pSI[t]*(1-pSI[t]))+S[lag+t-1]));
  SIGshape[t] = pSI[t]*SIGrate[t]*S[lag+t-1];
  Ihat[lag+t] ~ gamma(SIGshape[t],SIGrate[t]/repprop);"
  }
  if(proc=="p"){
    innerI <- "
  SIGrate[t] = 1;
  SIGshape[t] = pSI[t]*S[lag+t-1];
  Ihat[lag+t] ~ gamma(SIGshape[t],SIGrate[t]/repprop);"
    }
  if(proc=="nb"){
    innerI <- "
  SIGrate[t] = pDis/(pSI[t]*S[lag+t-1]+epsp);
  SIGshape[t] = pDis;
  Ihat[lag+t] ~ gamma(SIGshape[t],SIGrate[t]/repprop);"
  }
  code <- c(outterloop,innerI,innerSPSI)
  return(code)
}

process_stancode <- process_stanfun(proc=process)


