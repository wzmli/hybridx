targetname <- unlist(strsplit(rtargetname,"_"))

print(targetname)
print(targetname[2])


dirpath <- "./jags_dir/results/"
if(targetname[3] == "stan"){
dirpath <- "./stan_dir/results/"}
if(targetname[3] == "nim"){
dirpath <- "./nimble_dir/results/"}

print(dirpath)

fn <- list.files(path=dirpath,pattern=targetname[2])
ll <- lapply(fn, function(x)readRDS(paste(dirpath,x,sep="")))
cc <- do.call(c,ll)

saveRDS(cc,file=paste(dirpath,targetname[2],targetname[3],".RDS",sep=""))
