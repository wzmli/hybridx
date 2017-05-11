## generates bugstemplate

process_code <- processfun(ty=type,proc=process)
observation_code <- obsfun(ty=type,obsp=observation)

if(plat=="nim"){
cat(nimstart[1]
    , priorfun(ver=version,ty=type,pl=plat)
    , process_code[1]
    , observation_code[1]
    , iterloop[1]
    , process_code[2]
    , process_code[3]
    , observation_code[2]
    , iterloop[2]
    , nimstart[2]
    , file=paste("./nimble_dir/templates/",rtargetname,sep=""))
}

if(plat=="jags"){
cat("model{"
    , priorfun(ver=version,ty=type)
    , process_code[1]
    , observation_code[1]
    , iterloop[1]
    , process_code[2]
    , process_code[3]
    , observation_code[2]
    , iterloop[2]
    , "}",file=paste("./jags_dir/templates/",rtargetname,sep=""))
}  