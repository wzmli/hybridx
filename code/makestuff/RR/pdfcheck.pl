my $fn = $ARGV[0];

while(<>){
	last if $page=/\bPage\b/;
}

unless ($page) {
	unlink $fn or die "Could not unlink empty pdf file $fn";
	die "No pages in pdf file $fn";
}
