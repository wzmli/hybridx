%.page.pdf: %.Rout.pdf
	pdfnup --outfile $@ --nup '2x2' $<

%.wide.pdf: %.Rout.pdf
	pdfnup --outfile $@ --nup '2x1' $<
