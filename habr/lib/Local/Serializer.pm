package Local::Serializer;

use strict;
use warnings;
use Mouse;
use JSON::XS;

has 'json' => (is => 'rw', builder => '_json');

sub _json{
	JSON::XS->new->utf8;
}

sub to_json{
	my ($self, $obj)=@_;
	my %h = %{$obj};
	$self->json->encode( \%h );
}

sub to_jsonl{
	my ($self, $aref)=@_;
	my @r;
	foreach my $obj (@{$aref}){
		my $s=$self->to_json($obj);
		push @r, $s;
	}
	join "\n", @r;
}

sub to_jsona{
	my ($self, $aref)=@_;
	my @r;
	foreach my $obj (@{$aref}){
		my %h=%{$obj};
		push @r, \%h;
	}
	$self->json->encode( \@r );
}

1;
