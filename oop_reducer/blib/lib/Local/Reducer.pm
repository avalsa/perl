package Local::Reducer;

use strict;
use warnings;
use Mouse;
use Local::Row::Simple;
use Local::Row::JSON;

has 'source' => (is => 'rw', required => 1);
has 'row_class' => (is => 'rw', required => 1);
has 'initial_value' => (is => 'rw', required => 1);
has 'reduced' =>(is => 'rw', lazy => 1, builder => '_re_bu');

sub _re_bu{
	my $self=shift;
	return $self->initial_value;
}

sub get_data {
	my ($self, $fields)=@_;
	my $str=$self->source->next;
	return undef unless (defined($str));
	my $x=$self->row_class->new(str=>$str);
	my @res;
	for (my $i=0; $i<@{$fields}; $i++){
		push @res, $x->get($fields->[$i], 0);
	}
	return \@res;
	
}

1;
