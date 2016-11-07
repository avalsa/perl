package Local::Reducer::MaxDiff;

use strict;
use warnings;
use Mouse;

extends 'Local::Reducer';

has 'top' => (is => 'rw', required => 1);
has 'bottom' => (is => 'rw', required => 1);

sub _m_dif{
	my ($self, $t, $b)=@_;
	my $dif=$t>$b?$t-$b:$b-$t;
	$self->reduced($self->reduced>$dif?$self->reduced:$dif);
}

sub reduce_n{
	my ($self, $n)=@_;
	for (my $i=0; $i<$n; $i++){
		my $ar=$self->get_data([$self->top, $self->bottom]);
		last if (!defined($ar->[0]) or !defined($ar->[1]));
		$self->_m_dif($ar->[0], $ar->[1]);
	}
	return $self->reduced; 
}

sub	reduce_all{
	my $self=shift;
	my $ar;
	while (defined( $ar=$self->get_data([$self->top, $self->bottom])) and defined($ar->[0]) and defined($ar->[1]) ) {
		$self->_m_dif($ar->[0], $ar->[1]);
	}
	return $self->reduced;
}

1;
