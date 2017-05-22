## nimforecast
library(dplyr)
library(coda)

targetname <- unlist(strsplit(rtargetname,"[_]"))

mgitype <- unlist(strsplit(targetname[2],"[.]"))

#### helper functions ----
qtilesnames <- c("q2.5","q5","q10","q25","q50","q75","q90","q95","q97.5")

qlist <- c(0.025,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.975)

qt <- function(n){
  return(quantile(n,qlist,na.rm=TRUE))
}
### mean generation interval

mgi <- function(gs,gp,l=5){
  kshape <- function(i){
    return(i^(gs-1) * exp(-i/(gp*l)))
  }
  ki <- sapply(1:l,kshape)
  iki <- c(1:l) * ki
  return(sum(iki)/sum(ki))
}

#### forecast ----

nimfilenames <- list.files(path="./nimble_dir/data/"
                            ,pattern=paste(mgitype[1],"."
                                           ,mgitype[2],"."
                                           ,mgitype[3],"."
                                           ,mgitype[4],"."
                                           ,".",sep=""))

if(targetname[3]==1){
	nimfilenames <- nimfilenames[1:50]
}

if(targetname[3] == 2){
	nimfilenames <- nimfilenames[51:100]
}


geni <- function(n){
  nimobj <- readRDS(paste("./nimble_dir/data/",n,sep=""))
  
  name <- unlist(strsplit(n,"[.]"))
  nimmod <- nimobj[[1]]
  timeobj <- nimobj[[2]]
  dat <- nimobj[[3]]
  real <- mgi(gs=dat$kerShape,gp=dat$kerPos,l=5)
  time <- timeobj[1]
  gendf <- do.call(rbind,nimmod)
  gendf2 <- (data.frame(gendf) 
             %>% select(c(kerShape,kerPos))
				 %>% sample_n(8000)
             %>% rowwise()
             %>% transmute(gen=mgi(kerShape,kerPos))
  )
  gendf2[is.na(gendf2)] <- 0
  genlist <- gendf2 %>% ungroup() %>% mutate(splitcode=rep(1:4,each=2000))
  slist <- split(genlist,f=genlist$splitcode)
  mclist <- lapply(slist,as.mcmc)
  neff <- effectiveSize(mclist)
  qtiles <- sapply(gendf2,qt)
  genmat <- t(qtiles)
  colnames(genmat) <- qtilesnames
  gendf3 <- data.frame(type = name[1]
                       , version=name[2]
                       , process=name[3]
                       , observation=name[4]
                       , seed = name[5]
                       , parameters = "MGI"
                       , real = real
                       , platform = name[6]
                       , ESS = neff[1]
                       , time = time,
                       genmat)
  rownames(gendf3) <- NULL
  
  return(gendf3)
}
t1 <- system.time(nimgen <- lapply(nimfilenames,geni))
print(t1)
print(nimgen[[1]])

saveRDS(nimgen,file=paste("./nimble_dir/data/results/gen_",targetname[2],"_",targetname[3],".RDS",sep=""))
