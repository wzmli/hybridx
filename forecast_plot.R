## forecast plots

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

qfun <- function(x) data_frame(cov90=with(x,between(real,q5,q95))
                               , SAD = with(x,sad(q50,real))
                               , ERROR = with(x,error(q50,real))
                               , ERRORSQ = with(x,errorsq(q50,real))
                               , timeperESS = with(x,timeperESS)
                               , q50 = with(x,q50)
                               , q5 = with(x,q5)
                               , q95 = with(x,q95)
                               , real = with(x,real)
)



plat1 <- readRDS(input_files[1])
## need to fix in the pipeline: rename platforms for forecast stan and nimble
plat2 <- readRDS(input_files[2]) 
plat3 <- readRDS(input_files[3])

nimdf <- data.frame()
for(i in 1:length(plat2)){
  nimdf <- rbind(nimdf,plat2[[i]])
}
nimdf <- nimdf %>% mutate(platform = "nimble")

standf <- data.frame()
for(i in 1:length(plat3)){
  standf <- rbind(standf,plat3[[i]])
}
standf <- standf %>% mutate(platform = "stan") 

# fclist <- c(plat1,plat2,plat3)

jagsdf <- data.frame()
for(i in 1:length(plat1)){
  jagsdf <- rbind(jagsdf,plat1[[i]])
}

fclist <- rbind(jagsdf,nimdf,standf) %>% filter(complete.cases(.))

fc<- (fclist 
      # %>% bind_rows(.id="run")
      %>% mutate(real=real+realEps
                 , ESS=ESS+sampEps
                 , timeperESS=time/ESS)
      %>% ungroup()
      %>% group_by(seed,type,version,process,observation,platform,parameters) 
      %>% do(qfun(.))
      %>% ungroup() 
      %>% mutate(ERROR = ifelse(ERROR == -Inf,0,ERROR)
                 , ERRORSQ = ifelse(ERRORSQ == Inf, 0, ERRORSQ))
)

fcdat <- (fc
      %>% group_by(type,version,process,observation,platform,parameters)
      %>% dplyr::summarise(cov90=mean(cov90)
                           , TPES = mean(timeperESS)
                           , BIAS = median(ERROR)
                           , MSE = mean(ERRORSQ))
)

fcdat0 <- (fc
          %>% group_by(type,version,process,observation,platform)
          %>% dplyr::summarise(cov90=mean(cov90)
                               , TPES = mean(timeperESS)
                               , BIAS = median(ERROR)
                               , MSE = mean(ERRORSQ))
)


# mfc <- reshape2::melt(fc2,id=c("type","version","process","observation","platform","time","MSE",))

errorname <- function(x,a){
  return(paste(x,a,sep="_"))
}


fcdat1 <- (fcdat
  %>% ungroup()
  %>% mutate(process=errorname(process,"process")
        , observation=errorname(observation,"obs")
        , RMSE = sqrt(MSE)
        , parameters = parameters-10
        )
)

fcdat01 <- (fcdat0
           %>% ungroup()
           %>% mutate(process=errorname(process,"process")
                      , observation=errorname(observation,"obs")
                      , RMSE = sqrt(MSE)
                      # , obsnum = obsnum-15
           )
)

fcdat1$process <- factor(fcdat1$process,levels = c("bb_process"
                                                         , "nb_process"
                                                         , "b_process"
                                                         , "p_process"
                                                         ))

fcdat1$observation <- factor(fcdat1$observation,levels = c("bb_obs"
                                                 , "nb_obs"
                                                 , "b_obs"
                                                 , "p_obs"
))

fcdat01$process <- factor(fcdat01$process,levels = c("bb_process"
                                                   , "nb_process"
                                                   , "b_process"
                                                   , "p_process"
))

fcdat01$observation <- factor(fcdat01$observation,levels = c("bb_obs"
                                                           , "nb_obs"
                                                           , "b_obs"
                                                           , "p_obs"
))

fcdat2 <- (fcdat1
  %>% unite(type_ver,type,version)
  # %>% mutate(parameters="forecast")
)

fcdat02 <- (fcdat01
           %>% unite(type_ver,type,version)
           %>% mutate(parameters="forecast")
)


gg <- (ggplot(fcdat2,aes(x=parameters,y=BIAS,color=platform))
       + geom_point(size=3,aes(shape=type_ver))
       + scale_shape_manual(values=c(1,2,16,17),name="Method"
                            ,labels=c("Discrete","Dis. Decorrelation"
                                     ,"Continuous", "Cont. Decorrelation"))
       + ylab("BIAS")
       + xlab("Forecast Step")
       + facet_grid(observation~process)
       + theme_bw()
       + theme(axis.text.x = element_text(angle=0))
       + scale_color_brewer(palette = "Dark2",name="Platform",
                            labels=c("JAGS","NIMBLE","Stan"))
       
)
print(gg)

gg0 <- (ggplot(fcdat02,aes(x=observation,y=BIAS,color=platform))
       + geom_point(size=3,aes(shape=type_ver))
       + scale_shape_manual(values=c(1,2,16,17),name="Method"
                            ,labels=c("Discrete","Dis. Decorrelation"
                                      ,"Continuous", "Cont. Decorrelation"))
       + ylab("Grand Mean BIAS")
       + xlab("Observation process")
       + facet_grid(.~process)
       + theme_bw()
       + theme(axis.text.x = element_text(angle=0))
       + scale_color_brewer(palette = "Dark2",name="Platform",
                            labels=c("JAGS","NIMBLE","Stan"))
       
)
print(gg0)
 

gg1 <- (ggplot(fcdat2,aes(x=parameters,y=RMSE,color=platform))
       + geom_point(size=3,aes(shape=type_ver))
       + scale_shape_manual(values=c(1,2,16,17),name="Method"
                            ,labels=c("Discrete","Dis. Decorrelation"
                                      ,"Continuous", "Cont. Decorrelation"))
       + ylab("RMSE")
       + xlab("Forecast Step")
       + facet_grid(observation~process)
       + theme_bw()
       + theme(axis.text.x = element_text(angle=0))
       + scale_color_brewer(palette = "Dark2",name="Platform",
                            labels=c("JAGS","NIMBLE","Stan"))
       
)
print(gg1)

# gg01 <- (ggplot(fcdat02,aes(x=observation,y=RMSE,color=platform))
#         + geom_point(size=3,aes(shape=type_ver))
#         + scale_shape_manual(values=c(1,2,16,17),name="Method"
#                              ,labels=c("Discrete","Dis Decorrelation"
#                                        ,"Hybrid", "Hyb Decorrelation"))
#         + ylab("Grand Mean RMSE")
#         + xlab("Observation process")
#         + facet_grid(.~process)
#         + theme_bw()
#         + theme(axis.text.x = element_text(angle=0))
#         + scale_color_brewer(palette = "Set1",name="Platform",
#                              labels=c("JAGS","NIMBLE","Stan"))
#         
# )
# print(gg01)


gg2 <- (ggplot(fcdat2,aes(x=as.factor(parameters),y=cov90,color=platform))
       + geom_point(size=3,aes(shape=type_ver))
       + scale_color_brewer(palette = "Dark2",name="Platform",
                            labels=c("JAGS","NIMBLE","Stan"))
       + scale_shape_manual(values=c(1,2,16,17),name="Method"
                            ,labels=c("Discrete","Dis. Decorrelation"
                                      ,"Continuous", "Cont. Decorrelation"))
       + ylab("Coverage")
       + xlab("Forecast Step")
       # + ylim(c(0,1.2))
       + geom_hline(yintercept=0.9)
       + facet_grid(observation~process,scales = "free_y")
       + theme_bw()
       + theme(axis.text.x = element_text(angle=0))
       + annotate("rect",xmin=0,xmax=6,
                  ymin=0.9-2*sqrt(0.9*0.1/100),
                  ymax=0.9+2*sqrt(0.9*0.1/100),alpha=0.2)

)
print(gg2)

# 
# gg02 <- (ggplot(fcdat02,aes(x=parameters,y=cov90,color=platform))
#         + geom_point(size=3,aes(shape=type_ver))
#         + scale_color_brewer(palette = "Set1",name="Platform",
#                              labels=c("JAGS","NIMBLE","Stan"))
#         + scale_shape_manual(values=c(1,2,16,17),name="Method"
#                              ,labels=c("Discrete","Discrete Hyper"
#                                        ,"Hybrid", "Hybrid Hyper"))
#         + ylab("Coverage")
#         + xlab("Observation process")
#         # + ylim(c(0,1.2))
#         + geom_hline(yintercept=0.9)
#         + facet_grid(.~process,scales = "free_y")
#         + theme_bw()
#         + theme(axis.text.x = element_text(angle=0))
#         + annotate("rect",xmin=0,xmax=6,
#                    ymin=0.9-2*sqrt(0.9*0.1/100),
#                    ymax=0.9+2*sqrt(0.9*0.1/100),alpha=0.2)
#         
# )
# print(gg02)
# 
# gg3 <- (ggplot(fcdat2,aes(x=obsnum,y=timeperSS,color=platform))
#         + geom_point(size=3,aes(shape=type_ver))
#         + scale_shape_manual(values=c(1,2,16,17))
#         + scale_y_log10()
#         + xlab("Forecast Step")
#         # + ylim(c(0,1.2))
#         + facet_grid(observation~process)
#         + theme_bw()
#         + theme(axis.text.x = element_text(angle=60))
#         + ggtitle("Forecast")
#         
# )
# print(gg3)
# 
# gg4 <- (ggplot(fcdat2,aes(x=obsnum,y=ESSperSS,color=platform))
#         + geom_point(size=3,aes(shape=type_ver))
#         + scale_shape_manual(values=c(1,2,16,17))
#         + scale_y_log10()
#         # + ylim(c(0,1.2))
#         + facet_grid(observation~process)
#         + theme_bw()
#         + theme(axis.text.x = element_text(angle=60))
#         + ggtitle("Forecast")
#         
# )
# print(gg4)

# 
gg5 <- (ggplot(fcdat2,aes(x=parameters,y=TPES,color=platform))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete","Dis. Decorrelation"
                                       ,"Continuous", "Cont. Decorrelation"))
        + scale_y_log10()
        # + ylim(c(0,1.2))
        + ylab("Time per Effective Sample Size")
        + xlab("Forecast Step")
        + facet_grid(observation~process)
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        + scale_color_brewer(palette = "Dark2",name="Platform",
                             labels=c("JAGS","NIMBLE","Stan"))
        
)
print(gg5)

# gg6 <- (ggplot(fcdat2,aes(x=timeperSS,y=ESSperSS,color=platform))
#         + geom_point(size=3,aes(shape=type_ver))
#         + scale_shape_manual(values=c(1,2,16,17))
#         # + scale_y_log10()
#         # + ylim(c(0,1.2))
#         + facet_grid(observation~process)
#         + theme_bw()
#         + theme(axis.text.x = element_text(angle=60))
#         + ggtitle("Forecast")
#         
# )
# print(gg6)
# 

# gg7 <- (ggplot(fcdat2,aes(x=obsnum,y=SMB,color=platform))
#         + geom_point(size=3,aes(shape=type_ver))
#         + scale_shape_manual(values=c(1,2,16,17),name="Method"
#                              ,labels=c("Discrete","Discrete Hyper"
#                                        ,"Hybrid", "Hybrid Hyper"))
#         + ylab("Scaled Mean Bias")
#         + xlab("Forecast Step")
#         + facet_grid(observation~process)
#         + theme_bw()
#         + theme(axis.text.x = element_text(angle=0))
#         + scale_color_brewer(palette = "Set1",name="Platform",
#                              labels=c("JAGS","Nimble","Stan"))
#         
# )
# print(gg7)
