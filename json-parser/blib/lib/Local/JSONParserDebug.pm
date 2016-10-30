package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );
use feature 'say';

sub parse_json {
	my $source = shift;
	my ($ind, $struct)=($source =~ m/^\{.+/s)?parse_hash(1, $source):parse_array(1, $source);
	pos($source)=$ind;
	die "Bad sequence" unless ( $source =~m/\G\s*/gc );
	return $struct;
}

sub parse_array{
	say 'new parse_array';
	my ($ind, $str)=(shift, shift);
	my @res;
	pos($str)=$ind;
	for($str){
		my $prev=',';#val
		while (pos($str) < length($str)) {
			if (/\G([\{|\[])/gc) {
				say "got spec $1";
				my ($posr, $struct)=($1 eq '{')?parse_hash(pos($str), $str):parse_array(pos($str), $str);
				push @res, $struct;
				pos($str)=$posr;
				die "Bad sequence" if ($prev ne',');
				$prev='val';
			}
			elsif (/\G\]/gc) {
				say "got spec ]";
				say 'end parse_array';
				return (pos($str), \@res);
			}
			elsif(/\G\s+/gc){
				say "got s+";
			}
			elsif(/\G\,/gc){
				say "got ,";
				die "Bad sequence" if ($prev ne'val');
				$prev=',';
			}
			elsif(/\G\"(.*?[^\\])\"/gc){
				say "got qout_word $1";
				push @res, $1;
				die "Bad sequence" if ($prev ne',');
				$prev='val';
			}
			elsif(/\G([\+?|\-?]\d+\.?\d+)/gc){
				say "got signed num $1";
				push @res, 0+$1;
				die "Bad sequence" if ($prev ne',');
				$prev='val';
			}
			else {
				if(/\G(.)/gc){
				die "Bad sequence $1";}
			}
		}
	}	
}

sub parse_hash{
	say 'new parse_hash';
	my %res;
	my ($ind, $str)=(shift, shift);
	pos($str)=$ind;
	for($str){
		my $key;
		my $prev=',';#val, key, :
		while (pos($str) < length($str)) {
			if (/\G([\{|\[])/gc) {
				say "got spec $1";
				my ($posr, $struct)=($1 eq '{')?parse_hash(pos($str), $str):parse_array(pos($str), $str);
				$res{$key}=$struct;
				pos($str)=$posr;
				die "Bad sequence" if ($prev ne':');
				$prev='val';
			}
			elsif (/\G\}/gc) {
				say "got spec }";
				say 'end parse_hash';
				return (pos($str), \%res);
			}
			elsif(/\G\s+/gc){
				say "got s+";
			}
			elsif(/\G\:/gc){
				say "got :";
				die "Bad sequence" if ($prev ne'key');
				$prev=':';
			}
			elsif(/\G\,/gc){
				say "got ,";
				die "Bad sequence" if ($prev ne'val');
				$prev=',';
			}
			elsif(/\G\"(.*?[^\\])\"/gc){  
				say "got qout_word $1";
				if ($prev eq ','){ $key=$1; $prev='key'; }
				elsif ($prev eq ':'){ $res{$key}=$1; $prev='val'; }
				else { die "Bad sequence"; }
			}
			elsif(/\G([\+?|\-?]\d+\.?\d+)/gc){
				say "got signed num $1";
				die "Bad sequence" if ($prev ne':');
				$prev='val';
				$res{$key}=0+$1;
			}
			else {
				die "Bad sequence";
			}
		}
	}	
}

1;
