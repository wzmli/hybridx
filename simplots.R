library(ggplot2)
library(gridExtra)


load('.forecastplot_dis.1.b.b.3_jags.RData')

g1 <- gg+ ggtitle("dis.1.b.b.jags")+ theme(legend.position = "none") + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_hyb.1.b.nb.3_stan.RData")

g2 <- gg+ ggtitle("hyb.1.b.nb.stan")+ theme(legend.position = "none") + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load('.forecastplot_hyb.1.bb.p.3_stan.RData')


g3 <-gg+ ggtitle("hyb.1.bb.p.stan")+ theme(legend.position = "none") + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_dis.1.bb.bb.3_nim.RData")

g4 <- gg+ ggtitle("dis.1.bb.bb.nim")+ theme(legend.position = "none") + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g1,g2,g3,g4,nrow=2))
