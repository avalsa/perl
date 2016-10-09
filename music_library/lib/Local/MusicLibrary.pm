package Local::MusicLibrary;

use strict;
use Local::MusicLibraryParser;
use Local::MusicLibraryPrinter;
use Local::MusicLibraryCustomizer;

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


use Exporter 'import';
our @EXPORT = qw/out/;

sub out{
	(my $re, my $pa)=(shift, shift);
	my $songs= parse($re);
	my $params=parse_param($pa);
	$songs=customize($songs, $params);
	print_songs($songs, $params->{'--columns'});
}

1;
