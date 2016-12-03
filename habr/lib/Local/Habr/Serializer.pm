package Local::Habr::Serializer;

use strict;
use warnings;
use Mouse;
use JSON::XS;
use feature 'switch';
no warnings 'experimental';

has 'json' => (is => 'rw', builder => '_json');

sub _json{
	JSON::XS->new->utf8;
}

sub serialize{
	my ($self, $obj, $for)=@_;
	given ($for){
		when ('json')  	{ return $self->_to_json($obj); }
		when ('jsonl') 	{ return $self->_to_jsonl($obj); }
		default 		{ die "Such format not supported"; }
	} 
}

sub _to_json{
	my ($self, $obj)=@_;
	$self->json->encode( $obj );
}

sub _to_jsonl{
	my ($self, $aref)=@_;
	return $self->_to_json($aref) if (ref($aref) ne 'ARRAY');
	my @r;
	foreach my $obj (@{$aref}){
		my $s=$self->json->encode($obj);
		push @r, $s;
	}
	join "\n", @r;
}

1;
