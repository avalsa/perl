package Local::Reducer::Sum;

use strict;
use warnings;
use Mouse;

extends 'Local::Reducer';

has 'field' => (is => 'rw', required => 1);

sub reduce_n{
	my ($self, $n)=@_;
	my $val;
	for (my $i=0; $i<$n; $i++){
		$val=$self->get_data([$self->field])->[0];
		last unless (defined($val));
		$self->reduced($self->reduced+$val);
	}
	return $self->reduced; 
}

sub	reduce_all{
	my $self=shift;
	while (defined (my $x=$self->get_data([$self->field]))) {
		$self->reduced($self->reduced+$x->[0]);
	}
	return $self->reduced; 
}

1;
