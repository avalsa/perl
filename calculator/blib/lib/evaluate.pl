=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;
	return 'NaN' unless (defined $rpn);
	my @res=@{$rpn};
	my @st;
	foreach my $n (@res){
		given ($n) {
			when (/^(\d+\.\d*|\d+)$/) { # элемент содержит число
				push @st, $n;
			}
			when ([ '+']) {
				my $a=pop @st;
				my $b=pop @st;
				push @st, $a+$b;
			}
			when ([ '-']) {
				my $b=pop @st;
				my $a=pop @st;
				push @st, $a-$b;
			}
			when ([ '*']) {
				my $a=pop @st;
				my $b=pop @st;
				push @st, $a*$b;
			}
			when ([ '/']) {
				my $b=pop @st;
				my $a=pop @st;
				return 'NaN' if ($b==0);
				push @st, $a/$b;
			}
			when ([ '^']) {
				my $b=pop @st;
				my $a=pop @st;
				push @st, $a**$b;
			}
			when ([ 'U+']) {}
			when ([ 'U-']) {
				my $a=pop @st;
				push @st, -$a;
			}
		}

	}
	return pop @st;
}

1;
