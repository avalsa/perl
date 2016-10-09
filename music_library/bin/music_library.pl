#/usr/bin/env perl

use strict;
use Local::MusicLibrary;

#read params
my @params;
{
	my $line=shift @ARGV;
	if (defined $line){push(@params, $line); redo;}
}

#read songs
my @res;
while (<>){
	chomp;
	push @res, $_;
}

#print songs
out(\@res, \@params);

