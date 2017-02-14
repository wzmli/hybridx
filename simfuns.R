##' Basic chain beta-binomial simulator
## Reed-Frost 
## e.g. see http://depts.washington.edu/sismid09/software/Module_7/reedfrost.R
## or the somewhat lame Wikipedia page

##' @param beta prob. of adequate contact per infective
##' @param population size
##' @param effprop initial effective proportion of population
##' @param i0 initial infected
##' @param t0 initial time (unused)
##' @param numobs ending time
##' @param seed random number seed
##' @param repprop reporting observation probability (1 by default)
##' @return a data frame with columns (time, S, I, R) 

rbbinom <- function(n, prob, k, size){
  mtilde <- rbeta(n, k/(1-prob), k/prob)
  return(rbinom(n, prob=mtilde, size=size))
}

simm <- function(N=10000, effprop0=0.5, betasize0=1, repprop0=0.5,
                 Rshape0=5,Rrate0=5,
                 pDshape0=1,pDrate0=1,
                 repDshape0=1,repDrate0=1,
                 i0=1, lag=1,
                 kerSize0=1,
                 t0=1, numobs=20, seed=NULL,
                 ksshape0=1, ksrate0=1,
                 kerPos0=0.5){
  
  ## *all* infecteds recover in the next time step
  
  if (!is.null(seed)) set.seed(seed)
  tvec <- seq(1,(numobs+lag))
  n <- length(tvec)
  I <- Iobs <- S <- R <- pSI <- numeric(n)
  
  
  ##Initial conditions
  set.seed(seed)
  pDis <- rgamma(1,shape=pDshape0,rate=pDrate0)
  repDis <- rgamma(1,shape=repDshape0,rate=repDrate0)
  effprop <- rbeta(1,betasize0/(1-effprop0),betasize0/(effprop0))
  repprop <- rbeta(1,betasize0/(1-repprop0),betasize0/repprop0)
  kerShape <- rgamma(1,shape=ksshape0,rate=ksrate0) 
  kerPos <- rbeta(1,kerSize0/(1-kerPos0),kerSize0/kerPos0) 
  N0 <- round(effprop*N)
  ker <- exp( (kerShape-1)*log(1:lag) - (1:lag)/(kerPos*lag) )
  
  I[1:lag] <- i0
  S[1:lag] <- N0 - i0
  R[1:lag] <- N-N0
  Iobs[1:lag] <- 0
  R0 <- rgamma(n=1,shape=Rshape0,rate=Rrate0)
  beta <- (R0/N0) * ker/sum(ker)
  pSI[1:lag] <- 1 - exp(-sum(I[1:lag]*beta))
  ## Generate the Unobserved process I, and observables:
  
  for (t in 1:numobs){
    # set.seed(seed)
    I[lag+t] <- rbbinom(1,prob=pSI[lag+t-1],k=pDis,size=S[lag+t-1])
    S[lag+t] <- S[lag+t-1] - I[lag+t]
    R[lag+t] <- R[lag+t-1] + I[lag+t-1]
    pSI[lag+t] <- 1 - exp(-sum(I[(1+t):(lag+t)]*beta))
    Iobs[lag+t] <- rbbinom(1, prob=repprop, k=repDis, size=I[lag+t])
  }
  
  dat <- lme4:::namedList(S,I,R,TOT=S+I+R,Iobs,pSI,R0,effprop,repprop,kerSize,
                          kerPos,kerShape,pDis,repDis)
  # return(dat[(lag+1):(lag+numobs),])
  return(dat)
}