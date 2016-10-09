package Local::MusicLibraryParser;

use strict;
use 5.010;
use experimental qw(switch);

=encoding utf8

=head1 NAME

Local::MusicLibraryParser - parser

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Exporter 'import';
our @EXPORT = qw/parse parse_param/;


sub parse_param{
	my $l=shift;
	my %par=(
	'--band' => '',
	'--year' => '',
	'--album' => '',
	'--track' => '',
	'--format' => '',
	'--sort' => '',
	'--columns' => [0, 1, 2, 3, 4] );
	goto fin if ($l==undef);
	my @param=@{$l};
	{
		my $b=pop @param;
		my $a=pop @param;
		if ($a eq undef) {next;}
		$a=~ s/^\s+//;
		$b=~ s/^\s+//;
		if(exists($par{$a})){
			if ($a eq '--columns'){
				my @arr=split ',', $b;
				my @ids=();
				foreach my $x (@arr) {
					given($x){
						when ('band') {  push @ids, 0; }
						when ('year') {  push @ids, 1; }
						when ('album'){  push @ids, 2; }
						when ('track'){  push @ids, 3; }
						when ('format'){ push @ids, 4; }
						default{ die "Error::Bad param";}
					}
				}
				$par{$a}=\@ids;
			}
			else{
				$par{$a}=$b;
			}
		}
		else{
			die "Error::Bad param";
		}
		redo;
	}
	fin:
	foreach my $key (keys %par){
		delete $par{$key} if ($par{$key} eq '');
	}
	return \%par;
}

sub parse{
	my $i=shift;
	my @in=@{$i};
	
	my @res;
	foreach my $n (@in){
		my @a=split /\//, $n;
		shift @a;
		my @b=split / - /, $a[1];
		my @c=split /\./, $a[2];
		splice @a, 1, 1, @b;
		splice @a, 3, 1, @c;
		if ($a[0] eq undef || $a[1] eq undef || $a[2] eq undef || $a[3] eq undef || $a[4] eq undef){
			die "Error::Invalid intup";
		}
		else{
			push @res, \@a;
		}
	}
	return \@res;
}

1;
