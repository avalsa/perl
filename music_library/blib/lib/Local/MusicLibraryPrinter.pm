package Local::MusicLibraryPrinter;

use strict;

=encoding utf8

=head1 NAME

Local::MusicLibraryPrinter - print all songs in required way

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


use Exporter 'import';
our @EXPORT = qw/print_songs/;


my @so;#songs
my @si;#sizes of coloms
my @li;#id of columns to print

sub print_song{
	my $in=shift;
	my @song=@{$in};
	my @tmp=('|');
	foreach my $m (@li){
		push @tmp, ' ';
		my $size=$si[$m]-length($song[$m]);
		for (my $j=0; $j<$size; $j++){
			push @tmp, ' ';
		}
		push @tmp, $song[$m];
		push @tmp, ' |';
	}
	print join('', @tmp);
}

my $first;
my $mid;
my $last;
sub make_lines{
	my @f=('/');
	my @m=('|');
	my @l=('\\');
	foreach my $m (@li){
		push @f, '-'; push @m, '-'; push @l, '-';
		for (my $i=0; $i<$si[$m]; $i++){
			push @f, '-'; push @m, '-'; push @l, '-';		
		}
		push @f, '-'; push @m, '-'; push @l, '-';

		push @f, '-'; push @m, '+'; push @l, '-';
	}
	pop @f; pop @m; pop @l;
	push @f, '\\'; push @m, '|'; push @l, '/';
	$first=join '', @f;
	$mid=join '', @m;
	$last=join '', @l;
}

sub max{
	(my $a, my $b)=(shift, shift);
	return $a>$b?$a:$b;
}
sub calc_sizes{
	my $s_ba; my $s_ye; my $s_al; my $s_tr; my $s_fo;
	foreach my $n (@so){
		my @a=@{$n};
		$s_ba=max(length $a[0], $s_ba);
		$s_ye=max(length $a[1], $s_ye);
		$s_al=max(length $a[2], $s_al);
		$s_tr=max(length $a[3], $s_tr);
		$s_fo=max(length $a[4], $s_fo);
	}
	@si=($s_ba, $s_ye, $s_al, $s_tr, $s_fo);
}

sub print_songs{
	my $link=shift;
	return if ($link==undef);
	@so=@{$link};#songs
	return if (@so==undef);
	$link=shift;
	@li=@{$link};#list with ids of colomns to out
	return if (@li==undef);
	calc_sizes();
	make_lines();
	
	print $first."\n";
	my $i=0;
	for (; $i<$#so; $i++){
			print_song($so[$i]);
			print "\n";
			print $mid."\n";
	}
	print_song($so[$i]);
	print "\n";
	print $last."\n";
}

1;
