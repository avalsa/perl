package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

use feature 'say';
use Data::Dumper;
use DDP;

sub form_st{
	use Encode qw(encode decode);
	my $sr=shift;
	my $supstr;
	my @sm=split m//, $sr;
	my $i=0;
	while ($i<=$#sm){
		if ($sm[$i] eq '\\' and $i<$#sm){ 
			if ($sm[$i+1] eq '"'){ $supstr=$supstr."\"";$i+=2;next;}
			if ($sm[$i+1] eq 't'){ $supstr=$supstr."\t";$i+=2;next;}
			if ($sm[$i+1] eq 'n'){ $supstr=$supstr."\n";$i+=2;next;}
			if ($sm[$i+1] eq 'r'){ $supstr=$supstr."\r";$i+=2;next;}
			if ($sm[$i+1] eq 'u'){ my $w=join('',@sm[$i+2..$i+5]); $supstr=$supstr.chr(hex($w)); $i+=6; next;}
		}
		$supstr=$supstr.$sm[$i++];
	}
	return encode("utf8", $supstr);
	
}

sub parse_array{
	my ($vec, $begin, $size)=(shift, shift, shift);
	my @m;
	die "Error::SyntaxError" if ($vec->[$begin] ne '[');
	$begin++;
	my $i=$begin; 
	while ($i<=$size) {
		#read value
		my $val=$vec->[$i];
		if ($val eq ']'){ next;}
		#string or number
		if ($val =~m/^\"/ or $val =~m/^\d+\.\d*|\d+$/){
			$val=~s/^\"//;
			$val=~s/\"$//;
			$val=form_st($val);
			push @m, $val;
			$i++; next;
		}
		if ($val eq '{'){
			my($v, $e)=parse_hash($vec, $i, $size);
			push @m, $v;
			$i=++$e; next;
		}
		if ($val eq '['){
			my($v, $e)=parse_array($vec, $i, $size);
			push @m, $v;
			$i=++$e; next;
		}
		die "Error:It's something strange";	
	}
		continue{
			return (\@m, $i) if ($vec->[$i] eq ']');
			die "Error::NoComma" if ($vec->[$i++] ne ',');
		}
		#we mustn-t come here
	die "Error::SyntaxError";
}

sub parse_hash{
	my ($vec, $begin, $size)=(shift, shift, shift);
	my %h;
	die "Error::SyntaxError" if ($vec->[$begin] ne '{');
	$begin++;
	my $i=$begin; 
	while ($i<=$size) {
		#read key
		my $key=$vec->[$i++];
		if ($key eq '}'){$i--; next;}
		die "Error::NotKey" unless ($key=~m/^\"/);
		$key=~s/^\"//;
		$key=~s/\"$//;
		#read ":"
		die "Error::NoColon" if ($vec->[$i++] ne ':');
		#read value
		my $val=$vec->[$i];
		#string or number
		if ($val =~m/^\"/ or $val =~ m/^\d+\.\d*|\d+$/){
			$val=~s/^\"//;
			$val=~s/\"$//;
			$val=form_st($val);
			$key=form_st($key);
			$h{$key}=$val;
			$i++; next;
		}
		if ($val eq '{'){
			my($v, $e)=parse_hash($vec, $i, $size);
			$h{$key}=$v;
			$i=++$e; next;
		}
		if ($val eq '['){
			my($v, $e)=parse_array($vec, $i, $size);
			$h{$key}=$v;
			$i=++$e; next;
		}
		die "Error:It's something strange";
	}
		continue{
			return (\%h, $i) if ($vec->[$i] eq '}');
			die "Error::NoComma" if ($vec->[$i++] ne ',');
		}
		#we mustn-t come here
	die "Error::SyntaxError";
}

sub parse_json{
	#prepare work
	my $source = shift;
	my @par= split m{([\"\{\}\[\]\:\,\\])}, $source;
	@par=grep {length $_} @par;
	my $t=0;#0-wait open, 1-wait close
	my @par2;
	for (my $i=0; $i<=$#par; $i++){
		if ($par[$i] eq "\""){
			if ($par[$i-1] eq '\\'){
				push @par2, join('', pop @par2, $par[$i]); next;
			}
			if ($t==1){push @par2, join('', pop @par2, $par[$i]); $t=0;}
			else{push @par2, $par[$i]; $t=1;}
		}
		elsif ($t==1){push @par2, join('', pop @par2, $par[$i]);}
		else{push @par2, $par[$i];}
	}
	@par2=grep {length $_ and not $_=~m/^\s*$/} @par2;
	for (my $i=0; $i<=$#par2; $i++){
		$par2[$i]=0+$par2[$i] if (not $par2[$i]=~m/^\"/ and not $par2[$i]=~m/[\{\}\[\]\,\:\\]/);	
	}

	#create structre
	my $struct;
	my $end;#for check of correctness
	
	if ($par2[0] eq '{'){ ($struct, $end)=parse_hash(\@par2, 0, $#par2); }
		else { ($struct, $end)=parse_array(\@par2, 0, $#par2); }
	die "Error::SyntaxError" unless ($end==$#par2);
	#say "////////////my hash////////////////////////////";
	#p $struct;
	#say "////////////right hash/////////////////////////";
	#use JSON::XS; $struct=JSON::XS->new->utf8->decode($source);
	#p $struct;
	return $struct;
}



1;