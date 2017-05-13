## parameter plots
library(ggplot2)
library(plyr)
library(dplyr)
library(tidyr)

# realEps so we don't over-react to stochasticity in small simulated epidemics
realEps <- 0.5
## Why do we need a sample epsilon?
sampEps <- 0.5

# n1 <- jagsforecast[[1]]
between <- function(x,y,z) y<x & x<z
error <- function(x,y) log(x/y)
sad <- function(x,y){
  abs(x-y)/y
}

bias <- function(x,y){
  (x-y)
}

errorsq <- function(x,y){(log(x/y))^2}

qfun <- function(x){
	data_frame(cov90=with(x,between(real,q5,q95))
	, SAD = with(x,sad(q50,real))
   , ERROR = with(x,error(q50,real))
   , ERRORSQ = with(x,errorsq(q50,real))
   , timeperESS = with(x,timeperESS)
   , q50 = with(x,q50)
   , q5 = with(x,q5)
   , q95 = with(x,q95)
   , real = with(x,real)
	, time = with(x,time)
	, ESS = with(x,ESS)
	, RHAT = with(x,Rhat)
	)
}


plat1 <- readRDS(input_files[1])
plat2 <- readRDS(input_files[2])
plat3 <- readRDS(input_files[3])
parlist <- c(plat1[[1]],plat2[[1]],plat3[[1]])

# aa <- readRDS("temp.RDS")
# parlist <- aa[[1]]
pardf <- (parlist
          %>% bind_rows(.id="run")
          %>% mutate(timeperESS=time/ESS)
          %>% filter(parameters %in% c("R0","effprop","repprop"))
          %>% group_by(run,type,version,process,observation,platform,parameters) 
          %>% do(qfun(.))
          %>% ungroup() 
          %>% group_by(type,version,process,observation,platform,parameters)
          %>% dplyr::summarise(cov90=mean(cov90)
                               , TPES = mean(timeperESS)
                               , BIAS = median(ERROR)
                               , MSE = mean(ERRORSQ)
										 , Time = median(time)
										 , ESS50 = median(ESS)
										 , ESSmin = min(ESS)
										 , ESS25 = quantile(ESS,probs = c(0.25))
										 , Rhat90 = quantile(RHAT,probs=c(0.9))
										 , Rhat80 = quantile(RHAT,probs=c(0.8))
										 , Rhatmed = median(RHAT)
										 )
)

# pardf2 <- (pardf
#   %>% rowwise()
#   %>% mutate(RMSD=sqrt(dif)
#              , SRMSE = RMSD/real
#              )
# )
# 
errorname <- function(x,a){
  return(paste(x,a,sep="_"))
}

pardf3 <- (pardf
  %>% ungroup()
  %>% dplyr:::mutate(process=errorname(process,"process")
                    , observation=factor(observation,levels=c("bb","nb","b","p"))
                    , RMSE = sqrt(MSE)
                    )
  %>% unite(type_ver,type,version)
)

# pardf4 <- (pardf3
#            %>% ungroup()
#            %>% select(-c(cov90,TPES,BIAS,MSE,RMSE))
#            %>% group_by(type_ver,process,observation,platform,parameters)
#            %>% dplyr::summarise(Time = median(Time)
#                                 , ESS = median(ESS)
#            )
# )

# pardf3$process <- factor(pardf3$process,levels = c("bb_process"
#                                                  , "nb_process"
#                                                  , "b_process"
#                                                  , "p_process"
# ))
#
# pardf3$observation <- factor(pardf3$observation,levels = c("bb_obs"
#                                                          , "nb_obs"
#                                                          , "b_obs"
#                                                          , "p_obs"
# ))


gg <- (ggplot(pardf3,aes(x=observation,y=BIAS,color=platform))
       + geom_point(size=3,aes(shape=type_ver))
       + scale_shape_manual(values=c(1,2,16,17),name="Method"
                            ,labels=c("Discrete"
                                      # , "Dis. Decorrelation"
                                      , "Continuous"
                                      # , "Cont. Decorrelation"
                            )
       )
       + ylab("BIAS")
       + xlab("observation process")
       + facet_grid(parameters~process)
       + theme_bw()
       + theme(axis.text.x = element_text(angle=0))
       + scale_color_manual(name="Platform", values=c("black","red","blue"),
                            labels=c("JAGS","NIMBLE","Stan"))

)
print(gg)

gg2 <- (ggplot(pardf3,aes(x=observation,y=RMSE,color=platform))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete"
                                       # , "Dis. Decorrelation"
                                       , "Continuous"
                                       # , "Cont. Decorrelation"
                                       )
                             )
        + ylab("RMSE")
        + xlab("observation process")
        + facet_grid(parameters~process)
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        + scale_color_manual(name="Platform", values=c("black","red","blue"),
                             labels=c("JAGS","NIMBLE","Stan"))

)
print(gg2)



gg3 <- (ggplot(pardf3,aes(x=observation,y=cov90,color=platform))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete"
                                       # , "Dis. Decorrelation"
                                       , "Continuous"
                                       # , "Cont. Decorrelation"
                             )
        )
        + ylab("Coverage")
        + xlab("Observation process")
        # + ylim(c(0,1.2))
        + geom_hline(yintercept=0.9)
        + facet_grid(parameters~process,scales = "free_y")
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        + scale_color_manual(name="Platform", values=c("black","red","blue"),
                             labels=c("JAGS","NIMBLE","Stan"))
        + annotate("rect",xmin=0,xmax=6,
                   ymin=0.9-2*sqrt(0.9*0.1/100),
                   ymax=0.9+2*sqrt(0.9*0.1/100),alpha=0.2)

)
print(gg3)

gg4 <- (ggplot(pardf3,aes(x=observation,y=TPES,color=platform))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete"
                                       # , "Dis. Decorrelation"
                                       , "Continuous"
                                       # , "Cont. Decorrelation"
                             )
        )
        + scale_color_manual(name="Platform", values=c("black","red","blue"),
                             labels=c("JAGS","NIMBLE","Stan"))
        + ylab("Time per Effective Sample")
        + xlab("Observation process")
        # + ylim(c(0,1.2))
        + facet_grid(parameters~process,scales = "free_y")
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        + scale_y_log10()

)
print(gg4)







gg5 <- (ggplot(pardf3,aes(x=Time,y=ESS25,color=platform))
        + geom_errorbar(aes(ymin=ESSmin,ymax=ESS50))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete"
                                       # , "Dis. Decorrelation"
                                       , "Continuous"
                                       # , "Cont. Decorrelation"
                             )
        )
        + scale_color_manual(name="Platform", values=c("black","red","blue"),
                             labels=c("JAGS","NIMBLE","Stan"))
        + ylab("ESS (errorbars correspond to min, 25%, 50% quantiles)")
        + xlab("Time")
		  + scale_y_log10()
        # + ylim(c(0,1.2))
        + facet_grid(observation~process,scales = "free_y")
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        # + annotate("rect",xmin=0,xmax=6,
        #            ymin=0.9-2*sqrt(0.9*0.1/100),
        #            ymax=0.9+2*sqrt(0.9*0.1/100),alpha=0.2)

)

gg6 <- (ggplot(pardf3,aes(x=observation,y=Rhat80,color=platform))
        + geom_errorbar(aes(ymin=Rhatmed,ymax=Rhat90))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete"
                                       # , "Dis. Decorrelation"
                                       , "Continuous"
                                       # , "Cont. Decorrelation"
                             )
        )
        + scale_color_manual(name="Platform", values=c("black","red","blue"),
                             labels=c("JAGS","NIMBLE","Stan"))
        + ylab("Rhat errorbars correspond to 50%, 80%, 90% quantiles")
        + xlab("Observation Process")
        # + ylim(c(0,1.2))
        + facet_grid(parameters~process,scales = "free_y")
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        # + annotate("rect",xmin=0,xmax=6,
        #            ymin=0.9-2*sqrt(0.9*0.1/100),
        #            ymax=0.9+2*sqrt(0.9*0.1/100),alpha=0.2)

)
print(gg6)

print(gg5 %+% (pardf3 %>% filter(parameters=="R0")) + ggtitle("R0"))
print(gg5 %+% (pardf3 %>% filter(parameters=="effprop")) + ggtitle("Effective proportion"))
print(gg5 %+% (pardf3 %>% filter(parameters=="repprop")) + ggtitle("Reporting proportion"))


