
simm <- function(R00=5, N=10000, effprop0=0.5, betasize0=1,
                 Rshape0=5,Rrate0=5,
                 pDis0=1, 
                 i0=1, lag=1,
                 kerSize0=1,
                 t0=1, numobs=20, repprop0=0.5, repDis0=1, seed=NULL,
                 kerShape0=1,kerPos0=0.5){
  
  ## *all* infecteds recover in the next time step
  
  if (!is.null(seed)) set.seed(seed)
  tvec <- seq(1,(numobs+lag))
  n <- length(tvec)
  I <- Iobs <- S <- R <- pSI <- numeric(n)
  
  
  ##Initial conditions
  set.seed(seed)
  effprop <- rbeta(1,betasize0/(1-effprop0),betasize0/(effprop0))
  repprop <- rbeta(1,betasize0/(1-repprop0),betasize0/repprop0)
  kerShape <- kerShape0 #rnorm(1,mean=kerShape0,sd = 0.01)
  kerPos <- kerPos0 # rbeta(1,kerSize0/(1-kerPos0),kerSize0/kerPos0)
  N0 <- rbinom(1,prob=effprop,size=N)
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
    I[lag+t] <- rbinom(1,prob=pSI[lag+t-1],size=S[lag+t-1])
    S[lag+t] <- S[lag+t-1] - I[lag+t]
    R[lag+t] <- R[lag+t-1] + I[lag+t-1]
    pSI[lag+t] <- 1 - exp(-sum(I[(1+t):(lag+t)]*beta))
    Iobs[lag+t] <- rbinom(1, prob=repprop, size=I[lag+t])
  }
  
  dat <- lme4:::namedList(S,I,R,TOT=S+I+R,Iobs,pSI,R0,effprop,repprop,kerSize,
                          kerPos,kerShape,pDis,repDis)
  # return(dat[(lag+1):(lag+numobs),])
  return(dat)
}

system.time(sim <- simm(R00=R0
                        , N=N
                        , lag=lag
                        , betasize0=betaSize
                        , effprop0=effprop
                        , Rshape0=Rshape
                        , Rrate0=Rrate
                        , i0=i0
                        , repprop0=repprop
                        , kerShape0=kerShape
                        , kerPos0=kerPos
                        , kerSize0=kerSize
                        , repDis0=repDis
                        , pDis0 = pDis
                        , numobs=(numobs+forecast),
                        seed=seed
)
)

print(sim)