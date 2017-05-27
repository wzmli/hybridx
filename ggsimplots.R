library(dplyr)
library("ggplot2"); theme_set(theme_bw())
scale_colour_discrete <- function(...,palette="Dark2")
  scale_colour_brewer(...,palette=palette)
scale_fill_discrete <- function(...,palette="Set1")
  scale_fill_brewer(...,palette=palette)
zmargin <- theme(panel.margin=grid::unit(0,"lines"))
library("RColorBrewer")

dat1 <- (dat1
  %>% mutate(Model=factor(Model,levels=c("Discrete b.b"
                                         , "Cont. Decorrelation p.nb"
                                         , "Cont. Decorrelation bb.p"
                                         , "Discrete nb.bb")))
)

gg1 <- (ggplot(dat1,aes(x=parameters,y=obs))
	+ geom_line(aes(color=Platform,lty=obstype))
	+ geom_point()
	+ facet_wrap(~Model,labeller=label_both)
	+ geom_ribbon(aes(ymin=lower,ymax=upper,fill=lowertype),alpha=0.2)
	+ scale_fill_manual(values = c("blue","light blue"), labels = c("50%","90%"),name="Confidence Intervals")
	+ scale_linetype_manual(values=c(2,1),labels=c("Median","Observed"),name="Type")
	+ xlab("Time step")
	+ ylab("Reported cases")
	+ scale_y_continuous(trans="log1p")
	+ zmargin
)


print(gg1)



dat2 <- (dat2
         %>% mutate(Model=factor(Model,levels=c("Dis. Decorrelation p.b"
                                                , "Discrete b.bb"
                                                , "Cont. Decorrelation nb.p"
                                                , "Continuous bb.nb")))
)

gg2 <- gg1 %+% dat2


print(gg2)



dat3 <- (dat3
         %>% mutate(Model=factor(Model,levels=c("Cont. Decorrelation p.p"
                                                , "Discrete b.bb"
                                                , "Discrete bb.b"
                                                , "Cont. Decorrelation nb.nb")))
)

gg3 <- gg1 %+% dat3


print(gg3)


