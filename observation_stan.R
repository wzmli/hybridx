observation_stancode <- NULL

obs_stanfun <- function(obsp="p"){
  if(obsp %in% c("b","bb")){return("Pick a different distribution")}
  outterloop <- ""
  innerloop <- "
  obs[t] ~ poisson(Ihat[t+lag]);"
  if(obsp=="nb"){
    outterloop <- ""
    innerloop <- "
  obsMean[t] ~ gamma(repDis,repDis/(Ihat[t+lag]+epso));
  obs[t] ~ poisson(obsMean[t]);"
  }
  code <- c(outterloop,innerloop)
  return(code)
}

observation_stancode <- obs_stanfun(obsp=observation)