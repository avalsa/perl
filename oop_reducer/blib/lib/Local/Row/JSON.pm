package Local::Row::JSON;

use strict;
use warnings;
use Mouse;
use JSON::XS;

has 'str' => (is => 'ro', required => 1);

sub get{
	my ($self, $name, $default)=@_;
	my $h=JSON::XS->new->utf8->decode( $self->str );
	return defined($h->{$name})?$h->{$name}:$default;
}

1;