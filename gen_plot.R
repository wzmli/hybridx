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
plat2 <- readRDS(input_files[2]) 
plat3 <- readRDS(input_files[3])

jagsdf <- data.frame()
for(i in 1:length(plat1)){
	jagsdf <- rbind(jagsdf,plat1[[i]])
}

nimdf <- data.frame()
for(i in 1:length(plat2)){
	nimdf <- rbind(nimdf, plat2[[i]])
}

standf <- data.frame()
for(i in 1:length(plat3)){
	standf <- rbind(standf,plat3[[i]])
}

genlist <- rbind(jagsdf,nimdf,standf) %>% filter(complete.cases(.))
gen<- (genlist 
      %>% bind_rows(.id="run")
      %>% mutate(ESS=ESS+sampEps
                 , timeperESS=time/ESS)
      %>% ungroup()
      %>% group_by(run,type,version,process,observation,platform,parameters) 
      %>% do(qfun(.))
      %>% ungroup() 
      %>% mutate(ERROR = ifelse(ERROR == -Inf,0,ERROR)
                 , ERRORSQ = ifelse(ERRORSQ == Inf, 0, ERRORSQ))
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


gendat <- (gen 
          %>% ungroup()
          %>% mutate(process=errorname(process,"process")
                     , observation=errorname(observation,"obs")
                     # , obsnum = obsnum-15
          )
)

gendat$process <- factor(gendat$process,levels = c("bb_process"
                                                 , "nb_process"
                                                 , "b_process"
                                                 , "p_process"
))

gendat$observation <- factor(gendat$observation,levels = c("bb_obs"
                                                         , "nb_obs"
                                                         , "b_obs"
                                                         , "p_obs"
))

gendat2 <- (gendat
           %>% unite(type_ver,type,version)
           %>% mutate(parameters="MGI"
                      , RMSE = sqrt(MSE))
)



gg <- (ggplot(gendat2,aes(x=observation,y=BIAS,color=platform))
       + geom_point(size=3,aes(shape=type_ver))
       + scale_shape_manual(values=c(1,2,16,17),name="Method"
                            ,labels=c("Discrete","Dis. Decorrelation"
                                      ,"Continuous", "Cont. Decorrelation"))
       + ylab("BIAS")
       + xlab("observation process")
       + facet_grid(parameters~process)
       + theme_bw()
       + theme(axis.text.x = element_text(angle=0))
       + scale_color_brewer(palette = "Set1",name="Platform",
                            labels=c("Jags","Nimble","Stan"))
       
)
print(gg)

gg2 <- (ggplot(gendat2,aes(x=observation,y=RMSE,color=platform))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete","Dis. Decorrelation"
                                       ,"Continuous", "Cont. Decorrelation"))
        + ylab("RMSE")
        + xlab("observation process")
        + facet_grid(parameters~process)
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        + scale_color_brewer(palette = "Set1",name="Platform",
                             labels=c("Jags","Nimble","Stan"))
        
)
print(gg2)



gg3 <- (ggplot(gendat2,aes(x=observation,y=cov90,color=platform))
        + geom_point(size=3,aes(shape=type_ver))
        + scale_color_brewer(palette = "Set1",name="Platform",
                             labels=c("Jags","Nimble","Stan"))
        + scale_shape_manual(values=c(1,2,16,17),name="Method"
                             ,labels=c("Discrete","Dis. Decorrelation"
                                       ,"Continuous", "Cont. Decorrelation"))
        + ylab("Coverage")
        + xlab("Forecast Step")
        # + ylim(c(0,1.2))
        + geom_hline(yintercept=0.9)
        + facet_grid(parameters~process,scales = "free_y")
        + theme_bw()
        + theme(axis.text.x = element_text(angle=0))
        + annotate("rect",xmin=0,xmax=6,
                   ymin=0.9-2*sqrt(0.9*0.1/100),
                   ymax=0.9+2*sqrt(0.9*0.1/100),alpha=0.2)
        
)
print(gg3)
