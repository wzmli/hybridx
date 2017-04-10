cat("##############################################\n")
print(rtargetname)
cat("##############################################\n")

show <- objects()
exclude <- c("input_files", "csvname", "pdfname")
show <- sort(setdiff(show, exclude))

for(n in show){
	o <- get(n)
	c <- class(o)
	cat(n, " (", c, ")", "\n", sep="")
	print(summary(o))
}

# rdnosave
