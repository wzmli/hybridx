%.0.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 1 --outfile $@

%.1.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 2 --outfile $@

%.2.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 3 --outfile $@

%.3.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 4 --outfile $@

%.4.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 5 --outfile $@

%.5.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 6 --outfile $@

%.6.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 7 --outfile $@

%.7.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 8 --outfile $@

%.8.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 9 --outfile $@

%.9.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 10 --outfile $@

%-0.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 1 --outfile $@

%-1.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 2 --outfile $@

%-2.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 3 --outfile $@

%-3.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 4 --outfile $@

%-4.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 5 --outfile $@

%-5.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 6 --outfile $@

%-6.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 7 --outfile $@

%-7.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 8 --outfile $@

%-8.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 9 --outfile $@

%-9.pdf: %.pdf
	pdfjam --papersize '{7in,7in}' $< 10 --outfile $@

%.page.pdf: %.Rout.pdf
	pdfnup --outfile $@ --nup '2x2' $<
