observation_code <- NULL

obsfun <- function(ty="dis",obsp="b"){
  outterloop <- ""
  innerloop <-"
    obs[t] ~ dbin(repprop,I[t+lag])"
  if(obsp=="bb"){
    outterloop <- "
    repDis ~ dgamma(repDshape,repDrate)
    "
    innerloop <- "
    reporting[t] ~ dbeta(repDis/(1-repprop),repDis/repprop)
    obs[t] ~ dbin(reporting[t],I[t+lag])"
  }
  if(obsp=="p"){
    innerloop <- "
    obs[t] ~ dpois(repprop*I[t+lag])"
  }
  if(obsp=="nb"){
    outterloop <- "
    repDis ~ dunif(0,100)"
    innerloop <- "
    obsMean[t] ~ dgamma(repDis,repDis/(repprop*I[t+lag]+epso))
    obs[t] ~ dpois(obsMean[t])"
  }
  if(ty=="hyb"){ ###################################################################
    if(obsp=="p"){
      innerloop <- "
    obs[t] ~ dpois(Ihat[t+lag])"
    }
    if(obsp=="nb"){
      outterloop <- "
    repDis ~ dunif(0, 100)"
      innerloop <- "
    obsMean[t] ~ dgamma(repDis,repDis/(Ihat[t+lag]+epso))
    obs[t] ~ dpois(obsMean[t])"
    }
  }
  code <- c(outterloop,innerloop)
  return(code)
}
