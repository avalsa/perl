package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );
use Encode qw(encode decode);

sub parse_json {
	my $source = shift;
	$source=~s/^\s+//g;
	$source=decode("utf-8", $source);
	my $l=\$source;
	die "Bad sequence" unless ( $source =~ m/\G[\{\[]/gc);
	my $struct=($source =~ m/^\{.+/s)?parse_hash($l):parse_array($l);
	die "Bad sequence" unless ( $source =~m/\G\s*/gc);
	die "Bad sequence" unless ( defined($struct));
	return $struct;
}

sub  makestr{
	my $str=shift;
	my $res;
	pos($str)=0;
	for($str){
		while (pos($str) < length($str)) {
			if (/\G\\n/gc) { $res=$res . "\n";}
			elsif (/\G\\t/gc) { $res=$res . "\t";}
			elsif (/\G\\b/gc) { $res=$res . "\b";}
			elsif (/\G\\r/gc) { $res=$res . "\r";}
			elsif (/\G\\f/gc) { $res=$res . "\f";}
			elsif (/\G\\"/gc) { $res=$res . "\"";}
			elsif (/\G\\\\/gc) { $res=$res . "\\";}
			elsif (/\G\\\//gc) { $res=$res . "\/";}
			elsif (/\G\\u(\w{4})/gc) {$res=$res . chr(hex($1)); die "Bad sequence" unless ($1=~m/[\da-fA-F]{4}/);}
			elsif (/\G(.)/gc) { $res=$res . $1;}
		}
	}
	return $res;
}

sub parse_array{
	my ($str) = $_[0];
	my @res;
	for($$str){
		my $prev='[';#val ,,
		while (pos($$str) < length($$str)) {
			if (/\G([\{\[])/gc) {
				my $struct=($1 eq '{')?parse_hash($str):parse_array($str);
				push @res, $struct;
				die "Bad sequence" if ($prev ne',' and $prev ne'[');
				$prev='val';
			}
			elsif (/\G\]/gc) {return \@res;}
			elsif(/\G\s+/gc){}
			elsif(/\G\,/gc){
				die "Bad sequence" if ($prev ne'val');
				$prev=',';
			}
			elsif(/\G\"(.*?[^\\])\"/gc){
				my $ss=makestr($1);
				push @res, $ss;
				die "Bad sequence" if ($prev ne','  and $prev ne'[');
				$prev='val';
			}
			elsif(/\G(\-?\d+\.?\d*)/gc){
				push @res, 0+$1;
				die "Bad sequence" if ($prev ne',' and $prev ne'[');
				$prev='val';
			}
			else {
				die "Bad sequence";
			}
		}
	}
	undef;	
}

sub parse_hash{
	my ($str) = $_[0];
	my %res;
	for($$str){
		my $key;
		my $prev='{';#val, key, :, ,
		while (pos($$str) < length($$str)) {
			if (/\G([\{\[])/gc) {
				my $struct=($1 eq '{')?parse_hash($str):parse_array($str);
				$res{$key}=$struct;
				die "Bad sequence" if ($prev ne':');
				$prev='val';
			}
			elsif (/\G\}/gc) {
				die "Bad sequence" if ($prev ne 'val' and $prev ne '{'); 
				return \%res;
			}
			elsif(/\G\s+/gc){}
			elsif(/\G\:/gc){
				die "Bad sequence" if ($prev ne'key');
				$prev=':';
			}
			elsif(/\G\,/gc){
				die "Bad sequence" if ($prev ne'val');
				$prev=',';
			}
			elsif(/\G\"(.*?[^\\])\"/gc){  
				my $ss=makestr($1);
				if ($prev eq ',' or $prev eq '{'){ $key=$ss; $prev='key'; }
				elsif ($prev eq ':'){ $res{$key}=$ss; $prev='val'; }
				else { die "Bad sequence"; }
			}
			elsif(/\G(\-?\d+\.?\d*)/gc){
				die "Bad sequence" if ($prev ne':');
				$prev='val';
				$res{$key}=0+$1;
			}
			else {
				die "Bad sequence";
			}
		}
	}
	undef;	
}

1;
