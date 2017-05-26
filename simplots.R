library(ggplot2)
library(gridExtra)


load('.forecastplot_dis.1.b.b.12_nim.RData')

g1 <- gg+ ggtitle("dis.1.b.b.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_dis.1.b.bb.12_nim.RData")

g2 <- gg+ ggtitle("dis.1.b.bb.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load('.forecastplot_dis.1.bb.b.12_nim.RData')


g3 <-gg+ ggtitle("dis.1.bb.b.jags")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

load(".forecastplot_dis.1.bb.bb.12_nim.RData")

g4 <- gg+ ggtitle("dis.1.bb.bb.nim")+ theme(legend.position = "none") # + scale_y_continuous(trans="log1p",breaks=c(0,500,1000,2000,6000))

print(grid.arrange(g1,g2,g3,g4,nrow=2))
