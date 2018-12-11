##

dat <- data.frame(time = 1:numobs, cases = head(sim$Iobs,numobs))
print(plot(dat$time,dat$cases))
