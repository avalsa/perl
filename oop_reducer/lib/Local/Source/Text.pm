package Local::Source::Text;

use strict;
use warnings;
use Mouse;

extends 'Local::Source';

has 'delimiter' => (is => 'rw', default =>"\n");
has 'text' =>(is =>'rw', required => 1);

sub BUILD{
	my $self=shift;
	my @ar=split $self->delimiter, $self->text;
	$self->array(\@ar);
}

1;