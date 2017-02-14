# epi parameters
R0 <- 15

Rshape <- R0
Rrate <- R0/5


# scale parameters
effprop <- 0.5
repprop <- 0.5
effrep <- effprop*repprop
effrepprop <- log(repprop)/log(effrep)

betaSize <- 1
effa <- betaSize/(1-effprop)
effb <- betaSize/(effprop)
repa <- betaSize/(1-repprop)
repb <- betaSize/repprop

effrepa <- betaSize/(1-effrep)
effrepb <- betaSize/(effrep)
effreppropa <- betaSize/(1-effrepprop)
effreppropb <- betaSize/(effrepprop)



lag = 5
forecast = 5

# init values and constants
N <- 100000
i0 <- 1
N0 <- round(N*effprop)
numobs <- 10
eps <- 0.000000001
epsp <- 0.000000001
epso <- 0.000000001

#kernels

ker <- rep(1/lag,lag)
kerShape <- 5
kerPos <- 0.5
kerSize <- 2

ksshape <- kerShape
ksrate <- kerShape
kPa <- kerSize/(1-kerPos)
kPb <- kerSize/(kerPos)


#dispersion parameters
pDis <- 10
pDshape <- pDis
pDrate <- pDis

repDis <- 10
repDshape <- repDis
repDrate <- repDis

# repobsa <- 0.1
# repobsb <- 0.1


#hybrid parameters 
SIGshape <- 0.1
SIGrate <- 0.1

#MCMC stuff
#iterations?
mchains <- 4
