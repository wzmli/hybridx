library(ggplot2)
library(dplyr)
library(gridExtra)

dat1 <- dat2 <- dat3 <- data.frame()
load('.forecastplot_dis.1.b.b.12_nim.RData')

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="No"
        , Obs_Dispersion="No"
        , Platform="NIMBLE"
        ,Model="Discrete b.b"
      )
)
dat1 <- rbind(dat1,ddmelt)
g1 <- gg+ ggtitle("dis.1.b.b.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_hyb.2.p.nb.12_stan.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="No"
        , Obs_Dispersion="Yes"
        , Platform="Stan"
        , Model="Cont. Decorrelation p.nb"
      )
)

dat1 <- rbind(dat1,ddmelt)
g2 <- gg+ ggtitle("hyb.2.p.nb.stan")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load('.forecastplot_hyb.2.bb.p.12_jags.RData')

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="Yes"
        , Obs_Dispersion="No"
        , Platform="JAGS"
        , Model="Cont. Decorrelation bb.p"
      )
)
  
dat1 <- rbind(dat1,ddmelt)
g3 <-gg+ ggtitle("hyb.2.bb.p.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_dis.1.nb.bb.12_nim.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="Yes"
        , Obs_Dispersion="Yes"
        , Platform="NIMBLE"
        , Model="Discrete nb.bb")
)
dat1 <- rbind(dat1,ddmelt)
g4 <- gg+ ggtitle("dis.1.nb.bb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g1,g2,g3,g4,nrow=2))




## set 2 

load(".forecastplot_dis.2.p.b.138_jags.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="No"
        , Obs_Dispersion="No"
        , Platform="JAGS"
        , Model="Dis. Decorrelation p.b")
)
dat2 <- rbind(dat2,ddmelt)
g5 <- gg+ ggtitle("dis.2.p.b.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_dis.1.b.bb.138_nim.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="No"
        , Obs_Dispersion="Yes"
        , Platform="NIMBLE"
        , Model = "Discrete b.bb")
)
dat2 <- rbind(dat2,ddmelt)
g6 <- gg+ ggtitle("dis.1.b.bb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_hyb.2.nb.p.138_stan.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="Yes"
        , Obs_Dispersion="No"
        , Platform="Stan"
        , Model="Cont. Decorrelation nb.p")
)
dat2 <- rbind(dat2,ddmelt)
g7 <- gg+ ggtitle("hyb.2.nb.p.stan")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_hyb.1.bb.nb.138_nim.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="Yes"
        , Obs_Dispersion="Yes"
        , Platform="NIMBLE"
        , Model = "Continuous bb.nb")
)
dat2 <- rbind(dat2,ddmelt)
g8 <- gg+ ggtitle("hyb.1.bb.nb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g5,g6,g7,g8,nrow=2))



## set 3

load(".forecastplot_hyb.2.p.p.86_stan.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="No"
        , Obs_Dispersion="No"
        , Platform="Stan"
        , Model= "Cont. Decorrelation p.p")
)
dat3 <- rbind(dat3,ddmelt)
g5 <- gg+ ggtitle("hyb.2.p.p.stan")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_dis.1.b.bb.86_jags.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="No"
        , Obs_Dispersion="Yes"
        , Platform="JAGS"
        , Model = "Discrete b.bb")
)
dat3 <- rbind(dat3,ddmelt)
g6 <- gg+ ggtitle("dis.1.b.bb.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_dis.1.bb.b.86_nim.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="Yes"
        , Obs_Dispersion="No"
        , Platform="NIMBLE"
        , Model = "Discrete bb.b")
)
dat3 <- rbind(dat3,ddmelt)
g7 <- gg+ ggtitle("dis.2.bb.b.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_hyb.2.nb.nb.86_jags.RData")

ddmelt <- (ddmelt 
  %>% mutate(Trans_Dispersion="Yes"
        , Obs_Dispersion="Yes"
        , Platform="JAGS"
        , Model = "Cont. Decorrelation nb.nb")
)
dat3 <- rbind(dat3,ddmelt)
g8 <- gg+ ggtitle("hyb.2.nb.nb.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g5,g6,g7,g8,nrow=2))

