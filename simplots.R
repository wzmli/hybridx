library(ggplot2)
library(gridExtra)


load('.forecastplot_dis.1.b.b.12_nim.RData')

g1 <- gg+ ggtitle("dis.1.b.b.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_hyb.2.p.nb.12_stan.RData")

g2 <- gg+ ggtitle("hyb.2.p.nb.stan")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load('.forecastplot_hyb.2.bb.p.12_jags.RData')


g3 <-gg+ ggtitle("hyb.2.bb.p.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_dis.1.nb.bb.12_nim.RData")

g4 <- gg+ ggtitle("dis.1.nb.bb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g1,g2,g3,g4,nrow=2))




## set 2 

load(".forecastplot_dis.2.p.b.138_jags.RData")

g5 <- gg+ ggtitle("dis.2.p.b.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_dis.1.b.bb.138_nim.RData")

g6 <- gg+ ggtitle("dis.1.b.bb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_hyb.2.nb.p.138_stan.RData")

g7 <- gg+ ggtitle("hyb.2.nb.p.stan")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_hyb.1.bb.nb.138_nim.RData")

g8 <- gg+ ggtitle("hyb.1.bb.nb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g5,g6,g7,g8,nrow=2))



## set 3

load(".forecastplot_hyb.2.p.p.86_stan.RData")

g5 <- gg+ ggtitle("hyb.2.p.p.stan")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_dis.1.b.bb.86_jags.RData")

g6 <- gg+ ggtitle("dis.1.b.bb.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_dis.1.bb.b.86_nim.RData")

g7 <- gg+ ggtitle("dis.2.bb.b.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))


load(".forecastplot_hyb.2.nb.nb.86_jags.RData")

g8 <- gg+ ggtitle("hyb.2.nb.nb.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g5,g6,g7,g8,nrow=2))

