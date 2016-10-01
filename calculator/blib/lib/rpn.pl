=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub prior {#priority
	my $sym=shift;
	given ($sym) {
			when (['U+', 'U-']) {
				return 4;
			}
			when (['^']){ 
				return 3;				
			}
			when ([ '*','/']){ 
				return 2;
			}
			when ([ '+','-']){
				return 1;
			}	
		}
}

sub assoc {#associativity
	my $sym=shift;
	return 2 if ($sym eq '^' or $sym eq 'U+'or $sym eq 'U-');
	return 1;
}

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @res=@{$source};
	my @rpn;
	my @st;

	foreach my $n (@res) {
		if ($n=~ /^(\d+\.\d*|\d+)$/) {
			push @rpn, $n;
		}
		else {
			if ($n eq '('){push(@st, $n); next;}
			if ($n eq ')'){
				my $g='';
				while ($g ne '('){
					$g=pop @st;
					push (@rpn, $g) if ($g ne '(');
				}
				next;				
			}
			my $p=prior($n); my $os=assoc($n);
			if ($os==2){
				my $prg=0;
				do{
					my $g=pop @st;
					$prg=prior($g);
					if ($p<$prg){
						push @rpn, $g;
					}
					else {
						push @st, $g;
					}
				}
				while ($p<$prg);
			}
			else{
				my $prg=0;
				do{
					my $g=pop @st;
					$prg=prior($g);
					if ($p<=$prg){
						push @rpn, $g;
					}
					else {
						push @st, $g;
					}
				}
				while ($p<=$prg);
			}
			push @st, $n;
		} 
	}
	{
		my $g=pop @st;
		if (defined $g){
			push @rpn, $g;
			redo;
		}
	} 
	return \@rpn;
}

1;