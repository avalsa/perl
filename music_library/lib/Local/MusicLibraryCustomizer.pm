package Local::MusicLibraryCustomizer;

use strict;
use 5.010;
use experimental qw(switch);
=encoding utf8

=head1 NAME

Local::MusicLibraryCustomizer - apply user's options to songs

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


use Exporter 'import';
our @EXPORT = qw/customize/;

my @songs;

sub rem{
	(my $id, my $val)=(shift, shift);
	my $i=0;
	{
		next if ($i>$#songs);
		my @song=@{$songs[$i]};
		if ($id==1){
			if ($song[$id] != $val){
				splice @songs, $i, 1;
			}
			else{$i++;}
		}
		else{
			if ($song[$id] ne $val){
				splice @songs, $i, 1;
			}
			else{$i++;}
		}
		
		redo;
	}
}

sub customize{
	(my $so, my $pa)=(shift, shift);
	@songs=@{$so};
	my %par=%{$pa};
	foreach my $k (keys %par){
		given($k){
			when ('--band'){   rem(0, $par{$k}); }
			when ('--year'){   rem(1, $par{$k}); }
			when ('--album'){  rem(2, $par{$k}); }
			when ('--track'){  rem(3, $par{$k}); }
			when ('--format'){ rem(4, $par{$k}); }
			when('--sort'){
				given($par{$k}){
					when ('band'){   my @sortso=sort {$a->[0] cmp $b->[0]} @songs; @songs=@{\@sortso}; }
					when ('year'){   my @sortso=sort {$a->[1] <=> $b->[1]} @songs; @songs=@{\@sortso}; }
					when ('album'){  my @sortso=sort {$a->[2] cmp $b->[2]} @songs; @songs=@{\@sortso}; }
					when ('track'){  my @sortso=sort {$a->[3] cmp $b->[3]} @songs; @songs=@{\@sortso}; }
					when ('format'){ my @sortso=sort {$a->[4] cmp $b->[4]} @songs; @songs=@{\@sortso}; }
					default{ die "Bad param";}
				}
			}
		}
	}
	return \@songs;
}


1;
