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
	$source=dec($source);
	die "Bad sequence" unless ($source =~ m/^[\{|\[].+/s);
	my ($ind, $struct)=($source =~ m/^\{.+/s)?parse_hash(1, $source):parse_array(1, $source);
	pos($source)=$ind;
	die "Bad sequence" unless ( $source =~m/\G\s*/gc);
	die "Bad sequence" unless ( defined($struct));
	return $struct;
}

sub dec{
	my $str = shift;
	$str=decode("utf-8", $str);
	return $str;
}

sub  makestr{
	my $str=shift;
	my $res;
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
			elsif (/\G\\\//gc) { $res=$res . "\/";}
			elsif (/\G\\u(\w{4})/gc) {$res=$res . chr(hex($1));}
			elsif (/\G(.)/gc) { $res=$res . $1;}
		}
	}
	return $res;
}

sub parse_array{
	my ($ind, $str)=(shift, shift);
	my @res;
	pos($str)=$ind;
	for($str){
		my $prev='[';#val ,,
		while (pos($str) < length($str)) {
			if (/\G([\{\[])/gc) {
				my ($posr, $struct)=($1 eq '{')?parse_hash(pos($str), $str):parse_array(pos($str), $str);
				push @res, $struct;
				pos($str)=$posr;
				die "Bad sequence" if ($prev ne',' and $prev ne'[');
				$prev='val';
			}
			elsif (/\G\]/gc) {return (pos($str), \@res);}
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
}

sub parse_hash{
	my %res;
	my ($ind, $str)=(shift, shift);
	pos($str)=$ind;
	for($str){
		my $key;
		my $prev='{';#val, key, :, ,
		while (pos($str) < length($str)) {
			if (/\G([\{\[])/gc) {
				my ($posr, $struct)=($1 eq '{')?parse_hash(pos($str), $str):parse_array(pos($str), $str);
				$res{$key}=$struct;
				pos($str)=$posr;
				die "Bad sequence" if ($prev ne':');
				$prev='val';
			}
			elsif (/\G\}/gc) {
				die "Bad sequence" if ($prev ne 'val' and $prev ne '{'); 
				return (pos($str), \%res);
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
}

1;
