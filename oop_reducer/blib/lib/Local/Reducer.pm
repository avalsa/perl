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

sub reduce {
	my ($self, $fields)=@_;
	my $str=$self->source->next;
	return undef unless (defined($str));
	if ($self->row_class eq 'Local::Row::Simple'){
		my $x=Local::Row::Simple->new(str=>$str);
		my @res;
		for (my $i=0; $i<@{$fields}; $i++){
			push @res, $x->get($fields->[$i], 0);
		}
		return \@res;
	}
	elsif ($self->row_class eq 'Local::Row::JSON'){
		my $x=Local::Row::JSON->new(str=>$str);
		my @res;
		for (my $i=0; $i<@{$fields}; $i++){
			push @res, $x->get($fields->[$i], 0);
		}
		return \@res;
	}
	else{
		die "Bad row_class";
	}
}

1;
