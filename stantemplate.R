standatfun <- function(ver,proc,obs){
  verdat <- '
  real effa;
  real effb;
  real repa;
  real repb;
  '
  if(ver==2){verdat <- '
  real effrepa;
  real effrepb;
  real effreppropa;
  real effreppropb;
  '
  }
  procdat <- obsdat <- '
  '
  if(proc %in% c('bb')){
    procdat <- '
  real pDshape;
  real pDrate;
  real epsp;
  '
  }
  if(proc %in% c('nb')){
    procdat <- '
  real epsp;
  '
  }
  if(obs=='nb'){
    obsdat <- '
  real repDshape;
  real repDrate;
  real epso;'
  }
  return(c(verdat,procdat,obsdat))
}

stanparafun <- function(ver,proc,obs){
  verpara <- '
  real <lower=0,upper=1> repprop;
  real <lower=0,upper=1> effprop;
  '
  if(ver==2){verpara <- '
  real <lower=0,upper=1> effrep;
  real <lower=0,upper=1> effrepprop;
  '
  }
  procpara <- obspara <- '
  '
  if(proc %in% c('bb','nb')){
    procpara <- '
  real <lower=0,upper=100> pDis;
  '
  }
  if(obs=='nb'){
    obspara <- '
  real <lower=0,upper=100> repDis;
  real <lower=0> obsMean[numobs];
  '
  }
  return(c(verpara,procpara,obspara))
}

stanmodfun <- function(ver){
  vermod <- '
  effprop ~ beta(effa,effb);
  repprop ~ beta(repa,repb);
  '
  if(ver==2){vermod <- '
  effrep ~ beta(effrepa,effrepb);
  effrepprop ~ beta(effreppropa,effreppropb);
  '
  }
  
  return(c(vermod))
  }

standat <- c('
data {
  int<lower=0> numobs;
  int obs[numobs]; 
  int N;
  int i0;
  real Rshape;
  real Rrate;
  real eps;
  int lag;
  real ksshape;
  real ksrate;
  real kPa;
  real kPb;
  ','
}')

stanpara <- c('
parameters {
  real <lower=0> R0;
  real <lower=0> Ihat[numobs+lag];
  real <lower=0> kerShape;
  real <lower=0> kerPos;
  ','
}')

transparams <- function(ver){
  transpar <- ''
  if(ver==2){
    transpar <-'
transformed parameters {
  real effprop;
  real repprop;
  effprop = exp((1-effrepprop)*log(effrep));
  repprop = exp((effrepprop)*log(effrep));
}'
  return(transpar)
  }
  }

stanmodel <- c('
model {
  real ker[lag];
  real kerr[lag];
  vector[numobs+lag] S;
  vector[numobs+1] pSI;
  vector[numobs] SIGrate;
  vector[numobs] SIGshape;
  real N0;
  ','
  R0 ~ gamma(Rshape,Rrate);
  kerShape ~ gamma(ksshape,ksrate);
  kerPos ~ beta(kPa,kPb);
  N0 = N*effprop;
  ','
  for (t in 1:lag){
  Ihat[t] ~ gamma(i0,1/repprop);
  S[t] = N0 - Ihat[t]/repprop;
  ker[t] = exp((kerShape-1)*log(t) - (t)/(kerPos*lag));
  }
  for (t in 1:lag){
  kerr[t] = ker[t]/sum(ker[1:lag]);
  }
  pSI[1] = 1 - exp(-(R0/(N0*repprop))*dot_product(Ihat[1:lag],(kerr[1:lag])));
  ','
  }')

iterloop <- c('
  for(t in 1:numobs) {'
  ,'
  }')
if(plat == 'stan'){
cat(standat[1]
    ,standatfun(ver=version,proc=process,obs=observation)
    ,standat[2]
    ,stanpara[1]
    ,stanparafun(ver=version,proc=process,obs=observation)
    ,stanpara[2]
    ,transparams(ver=version)
    ,stanmodel[1]
    ,stanmodfun(ver=version)
    ,stanmodel[2]
    ,process_stancode[1]
    ,observation_stancode[1]
    ,stanmodel[3]
    ,iterloop[1]
    ,process_stancode[2]
    ,process_stancode[3]
    ,observation_stancode[2]
    ,iterloop[2]
    ,stanmodel[4]
    ,file = paste(rtargetname)
)
}