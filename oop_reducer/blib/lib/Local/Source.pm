package Local::Source;

use strict;
use warnings;
use Mouse;

has 'array' => (is => 'rw');
has 'ind' => (is => 'rw', default => 0);

sub next{
	my ($self)=shift;
	if ($self->ind<$self->array) {
		my $x=$self->array->[$self->ind];
		$self->ind($self->ind+1);
		return $x;
	}
}

1;