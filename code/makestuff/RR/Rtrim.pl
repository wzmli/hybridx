use strict;
 
undef $/;
my $f = <>;
 
$f =~ s/.*# End RR preface\n*//s;
$f =~ s/\n*# Begin RR postscript.*/\n/s;
print $f;
