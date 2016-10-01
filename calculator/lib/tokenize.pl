=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
#use warnings;
#use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize {
	chomp(my $expr = shift);
	$expr=~s/\s//g;
	my @res=split m{([-+*/^()e])}, $expr;

	#check all OK with brackets
	my $brackets=0;
	foreach my $n (@res) {
  		if ($n eq "(") { $brackets++; }
  		elsif ($n eq")"){ $brackets--; if ($brackets<0) {die "Error::brackets"}	}
	}
	if ($brackets>0) {die "Error::brackets";}

	#seek for exponential numbers and begins with dot
	for (my $i=0; $i<=$#res; $i++){
		next if ($res[$i] eq "");
		given ($res[$i]) {
			when (/^(\d*\.\d*|\d+)$/) { # элемент содержит число
				{$res[$i]=0+$res[$i];}
			}
			when ([ '+', 'e','-', '*', '/', '^', ')', '(' ]) {}
			default{
				die "Error::punctuation";
			}
		}
		if ($res[$i] eq "e"){
			if ($res[$i+1] eq ""){
				if ($res[$i+2] eq "+" or $res[$i+2] eq "-"){
					$res[$i]=0+join("",@res[$i-1..$i+3]);
					$res[$i-1]=""; $res[$i+2]=""; $res[$i+3]="";
				}
				else {die "Error::punctuation";}
			}
			else{
				$res[$i]=0+join("",@res[$i-1..$i+1]);
				$res[$i-1]=""; $res[$i+1]="";
			}
		}
	}
	
	#clear from empty words
	for (my $i=$#res; $i>=0; $i--){
	 splice(@res, $i, 1) if ($res[$i] eq ""); 
	}

	#add unary and check punctuation
	die "Error::punctuation" unless ($res[0]=~ /^(\d+\.\d*|\d+)$/ or $res[0] eq "(" or $res[0] eq "+" or $res[0] eq "-" );
	$res[0]="U+" if ($res[0] eq "+");
	$res[0]="U-" if ($res[0] eq "-");
	my $pre=0; #()2, +-*/^3, U+U-4, d5  
	for (my $i=0; $i<=$#res; $i++){
		given ($res[$i]) {
			when (/^(\d+\.\d*|\d+)$/) { # элемент содержит число
				if ($pre==2 and $res[$i-1] eq ")") {die "Error::punctuation";}
				die "Error::punctuation" if ($pre==5);
				$pre=5;
			}
			when ([ '(', ')']) {
				if ($pre==5 and $res[$i] eq "(") {die "Error::punctuation";}
				$pre=2;
			} 
			when ([ '+','-']){
				my $it=3; 
				if ($pre==3 or $pre==4){
					$res[$i]="U".$res[$i];
					$it=4;
				}
				if ($pre==2 and $res[$i-1] eq "(") {$res[$i]="U".$res[$i]; $it=4;}
				$pre=$it;
			}
			when ([ '*','/', '^']){ 
				if ($pre==3 or $pre==4){die "Error::punctuation";}
				if ($pre==2 and $res[$i-1] eq "(") {die "Error::punctuation";}
				$pre=3;
			}
			default {
				die "Error::punctuation" if ($i!=0);
			}
		}
	}
	die "Error::punctuation" unless ($res[$#res]=~ /^(\d+\.\d*|\d+)$/ or $res[$#res] eq ")");
	return \@res;
}

1;