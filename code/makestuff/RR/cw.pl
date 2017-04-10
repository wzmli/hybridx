use strict;
use 5.10.1;

say "{|";
while(<>){
	my $ln = "| ";
	$ln .= join " || ", split /, */;
	$ln =~ s/[|]/!/g if $.==1;
	print("|-\n$ln");
}
say "|}";
