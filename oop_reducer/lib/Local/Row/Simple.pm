package Local::Row::Simple;

use strict;
use warnings;
use Mouse;

has 'str' => (is => 'ro', required => 1);

sub get{
	my ($self, $name, $default)=@_;
	my %h=split m/[:,]/, $self->str;
	return defined($h{$name})?$h{$name}:$default;
}

1;