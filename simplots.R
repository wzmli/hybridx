library(ggplot2)
library(gridExtra)


load('.forecastplot_dis.1.bb.bb.3_jags.RData')

g1 <- gg+ theme(legend.position = "none")

load(".forecastplot_hyb.1.bb.nb.12_stan.RData")


g2 <- gg + theme(legend.position = "none")

load('.forecastplot_dis.1.b.b.19_jags.RData')


g3 <- gg + theme(legend.position = "none")

load(".forecastplot_dis.1.bb.b.19_nim.RData")

g4 <- gg + theme(legend.position = "none")

print(grid.arrange(g1,g2,g3,g4,nrow=2))
