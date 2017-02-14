## nimforecast
library(dplyr)
library(coda)

fctype <- unlist(strsplit(rtargetname,"[.]"))

#### helper functions ----
qtilesnames <- c("q2.5","q5","q10","q25","q50","q75","q90","q95","q97.5")

qlist <- c(0.025,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.975)

fcI <- function(i1,i2,i3,i4,i5,kerS,kerP,R_0,repp,effp,S, process_error,pdis){
  I <- c(i1,i2,i3,i4,i5)
  ker <- exp((kerS-1)*log(1:lag) - (1:lag)/(kerP*lag))
  beta <- (R_0/(N*effp)) * ker/sum(ker)
  pSI <- 1 - exp(-sum(I[1:lag]*beta))
  I_new <- rbinom(1,size=S,prob = pSI)
  if(process_error == "bb"){
    I_new <- rbbinom(1,prob=pSI,k=pdis,size=S)
  }
  if(process_error == "nb"){
    I_new <- rnbinom(1,size=pdis,mu=pSI*S)
  }
  if(process_error == "p"){
    I_new <- rpois(1,pSI*S)
  }
  return(I_new)
}


fcIhat <- function(i1,i2,i3,i4,i5,kerS,kerP,R_0,repp,effp,S, process_error,pdis){
  Ihat <- c(i1,i2,i3,i4,i5)
  ker <- exp((kerS-1)*log(1:lag) - (1:lag)/(kerP*lag))
  beta <- (R_0/(N*effp)) * ker/sum(ker)
  pSI <- 1 - exp(-sum(Ihat[1:lag]*beta/repprop))
  SIGrate <- 1/(1-pSI)
  SIGshape <- pSI*SIGrate*S
  if(process_error == "bb"){
    SIGrate <- (pdis/(pSI*(1-pSI))+1)/((1-pSI)*(pdis/(pSI*(1-pSI))+S))
    SIGshape <- pSI*SIGrate*S
  }
  if(process_error == "nb"){
    SIGrate <- pdis/(pSI*S)
    SIGshape <- pdis
  }
  if(process_error == "p"){
    SIGrate <- 1
    SIGshape <- pSI*S
  }
  Ihat_new <- rgamma(1,shape=SIGshape,rate=SIGrate/repprop)
  return(Ihat_new)
}

fcobs <- function(x,obsp,repdis,repp,tt){
  obsMean <- x
  if(obsp == "b"){
    fc <- rbinom(1,x,repp)
  }
  if(obsp == "bb"){
    fc <- rbbinom(1,repp,repdis,x)
  }
  if(obsp == "nb"){
    fc <- rnbinom(1,size=repdis,mu=x*repp)
  }
  if(obsp == "p"){
    fc <- rpois(1,x*repp)
  }
  if(tt=="hyb"){
    if(obsp == "nb"){
      obsMean <- rgamma(1,repdis,repdis/x)
    }
    fc <- rpois(1,obsMean)
  }
  return(fc)
}

S_update <- function(S_old,I_new,repp,tt="hyb"){
  S_new <- S_old - I_new/repp
  if(tt == "dis"){
    S_new <- S_old - I_new
  }
  return(S_new)
}

qt <- function(n){
  return(quantile(n,qlist,na.rm=TRUE))
}

#### forecast ----

nimfilenames <- list.files(path="./nim10k/"
                            ,pattern=paste(fctype[3],"."
                                           ,fctype[4],"."
                                           ,fctype[5],"."
                                           ,fctype[6],"."
                                           ,".",sep=""))

forecast <- function(n){
  nimobj <- readRDS(paste("./nim10k/",n,sep=""))
  
  name <- unlist(strsplit(n,"[.]"))
  nimmod <- nimobj[[1]]
  timeobj <- nimobj[[2]]
  dat <- nimobj[[3]]
  real <- dat$Iobs[16:20]
  time <- timeobj[1]
  tempdf <- do.call(rbind,nimmod)
  fcdf <- data.frame(type = name[1]
                     , version=name[2]
                     , process=name[3]
                     , observation=name[4]
                     , seed = name[5]
                     , platform = name[7]
                     , time = time,
                     tempdf)
  type <- name[1]
  if(type=="hyb"){
    fcdf2 <- (fcdf 
              %>% mutate(pos1 = which(colnames(.)=="Ihat.6.")
                         , pos10 = which(colnames(.)=="Ihat.15.")
                         , S15 = N*effprop - (Reduce("+",.[pos1:pos10]))/repprop
                         , pDis = ifelse(process %in% c("bb","nb"),pDis,1)
                         , repDis = ifelse(observation == "nb",repDis,1)
              )
              %>% rowwise()
              %>% mutate(Ihat.16. = fcIhat(i1=Ihat.11. , i2=Ihat.12. , i3=Ihat.13.
                                           , i4=Ihat.14. , i5=Ihat.15. , kerS=kerShape
                                           , kerP=kerPos , R_0=R0, repp=repprop
                                           , effp=effprop, S=S15, process_error=process,pdis=pDis)
                         , S16 = S_update(S15,Ihat.16.,repprop)
                         , fc1 = fcobs(Ihat.16.,observation,repdis=repDis,repp=repprop,tt=type)
                         , Ihat.17. = fcIhat(i1=Ihat.12. , i2=Ihat.13. , i3=Ihat.14.
                                             , i4=Ihat.15. , i5=Ihat.16. , kerS=kerShape
                                             , kerP=kerPos , R_0=R0, repp=repprop
                                             , effp=effprop, S=S16, process_error=process,pdis=pDis)
                         , S17 = S_update(S16,Ihat.17.,repprop)
                         , fc2 = fcobs(Ihat.17.,observation, repdis=repDis,repp=repprop,tt=type)
                         , Ihat.18. = fcIhat(i1=Ihat.13. , i2=Ihat.14. , i3=Ihat.15.
                                             , i4=Ihat.16. , i5=Ihat.17. , kerS=kerShape
                                             , kerP=kerPos , R_0=R0, repp=repprop
                                             , effp=effprop, S=S17, process_error=process, pdis=pDis)
                         , S18 = S_update(S17,Ihat.18.,repprop)
                         , fc3 = fcobs(Ihat.18.,observation,repdis=repDis,repp=repprop,tt=type)
                         , Ihat.19. = fcIhat(i1=Ihat.14. , i2=Ihat.15. , i3=Ihat.16.
                                             , i4=Ihat.17. , i5=Ihat.18. , kerS=kerShape
                                             , kerP=kerPos , R_0=R0, repp=repprop
                                             , effp=effprop, S=S18, process_error=process,pdis=pDis)
                         , S19 = S_update(S18,Ihat.19.,repprop)
                         , fc4 = fcobs(Ihat.19.,observation,repdis=repDis,repp=repprop,tt=type)
                         , Ihat.20. = fcIhat(i1=Ihat.15. , i2=Ihat.16. , i3=Ihat.17.
                                             , i4=Ihat.18. , i5=Ihat.17. , kerS=kerShape
                                             , kerP=kerPos , R_0=R0, repp=repprop
                                             , effp=effprop, S=S19, process_error=process,pdis=pDis)
                         , S20 = S_update(S19,Ihat.20.,repprop)
                         , fc5 = fcobs(Ihat.20.,observation,repdis=repDis,repp=repprop,tt=type)
              )
              %>% select(c(fc1,fc2,fc3,fc4,fc5))
    )
  }
  if(type=="dis"){
    fcdf2 <- (fcdf 
              %>% mutate(pos1 = which(colnames(.)=="I.6.")
                         , pos10 = which(colnames(.)=="I.15.")
                         , S15 = round(N*effprop) - (Reduce("+",.[pos1:pos10]))
                         , pDis = ifelse(process %in% c("bb","nb"),pDis,1)
                         , repDis = ifelse(observation == "nb",repDis,1)
              )
              %>% rowwise()
              %>% mutate(I.16. = fcI(i1=I.11. , i2=I.12. , i3=I.13.
                                     , i4=I.14. , i5=I.15. , kerS=kerShape
                                     , kerP=kerPos , R_0=R0, repp=repprop
                                     , effp=effprop, S=S15, process_error=process,pdis=pDis)
                         , S16 = S_update(S15,I.16.,repprop,type)
                         , fc1 = fcobs(I.16.,observation,repdis=repDis,repp=repprop,tt=type)
                         , I.17. = fcI(i1=I.12. , i2=I.13. , i3=I.14.
                                       , i4=I.15. , i5=I.16. , kerS=kerShape
                                       , kerP=kerPos , R_0=R0, repp=repprop
                                       , effp=effprop, S=S16, process_error=process,pdis=pDis)
                         , S17 = S_update(S16,I.17.,repprop,type)
                         , fc2 = fcobs(I.17.,observation, repdis=repDis,repp=repprop,tt=type)
                         , I.18. = fcI(i1=I.13. , i2=I.14. , i3=I.15.
                                       , i4=I.16. , i5=I.17. , kerS=kerShape
                                       , kerP=kerPos , R_0=R0, repp=repprop
                                       , effp=effprop, S=S17, process_error=process, pdis=pDis)
                         , S18 = S_update(S17,I.18.,repprop,type)
                         , fc3 = fcobs(I.18.,observation,repdis=repDis,repp=repprop,tt=type)
                         , I.19. = fcI(i1=I.14. , i2=I.15. , i3=I.16.
                                       , i4=I.17. , i5=I.18. , kerS=kerShape
                                       , kerP=kerPos , R_0=R0, repp=repprop
                                       , effp=effprop, S=S18, process_error=process,pdis=pDis)
                         , S19 = S_update(S18,I.19.,repprop,type)
                         , fc4 = fcobs(I.19.,observation,repdis=repDis,repp=repprop,tt=type)
                         , I.20. = fcI(i1=I.15. , i2=I.16. , i3=I.17.
                                       , i4=I.18. , i5=I.19. , kerS=kerShape
                                       , kerP=kerPos , R_0=R0, repp=repprop
                                       , effp=effprop, S=S19, process_error=process,pdis=pDis)
                         , S20 = S_update(S19,I.20.,repprop,type)
                         , fc5 = fcobs(I.20.,observation,repdis=repDis,repp=repprop,tt=type)
              )
              %>% select(c(fc1,fc2,fc3,fc4,fc5))
    )
  }
  
  fcdf2[is.na(fcdf2)] <- 0
  fclist <- fcdf2 %>% ungroup() %>% mutate(splitcode=rep(1:4,each=10000))
  slist <- split(fclist,f=fclist$splitcode)
  mclist <- lapply(slist,as.mcmc)
  neff <- effectiveSize(mclist)
  qtiles <- sapply(fcdf2,qt)
  forecastmat <- t(qtiles)
  colnames(forecastmat) <- qtilesnames
  fcdf3 <- data.frame(type = name[1]
                      , version=name[2]
                      , process=name[3]
                      , observation=name[4]
                      , seed = name[5]
                      , parameters = 11:15
                      , real = real
                      , platform = name[7]
                      , ESS = neff[1:5]
                      , time = time,
                      forecastmat)
  rownames(fcdf3) <- NULL
  
  return(fcdf3)
}
t1 <- system.time(nimforecast <- lapply(nimfilenames,forecast))
print(t1)
print(nimforecast[[1]])

saveRDS(nimforecast,file=paste(fctype[2], fctype[3]
                                ,fctype[4]
                                ,fctype[5]
                                ,fctype[6]
                                ,"fc.rds",sep="_"))
