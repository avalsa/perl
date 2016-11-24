package Local::Habr;

use strict;
use warnings;
use Local::Database;
use Local::Browser;
use Local::Serializer;
use Mouse;

has 'db' => (is => 'rw', builder => '_db');
has 'br' => (is => 'rw', builder => '_br');
has 'se' => (is => 'rw', builder => '_se');

sub _db{ Local::Database->new; }

sub _br{ Local::Browser->new; }

sub _se{ Local::Serializer->new; }

sub get_user_info{
	my ($self, $name, $format, $ref)=@_;
	goto e1 if ($ref);
	my $user;
	$user=$self->db->get_user_info($name);
	return $self->se->to_json($user) if (defined($user));
	e1:
	$user=$self->br->get_user_info($name);
	$self->db->insert_user($user);
	return $self->se->to_json($user);
}

sub get_user_info_by_post{
	my ($self, $id, $format, $ref)=@_;
	my $pot=$self->db->get_post_info($id);
	goto e2 if ($ref);
	my $us;
	if (defined($pot)){
		$us=$self->db->get_user_info($pot->author);
		$us=$self->br->get_user_info($pot->author) unless (defined($us));
		return $self->se->to_json($us);
	}
	e2:
	my ($post, $user, $coms)=$self->br->get_post_info($id);
	$self->db->insert_user($user);
	$self->db->insert_post($post);
	foreach my $com ( @{$coms} ) {
		$self->db->insert_commentor($com);
	}
	return $self->se->to_json($user);
}

sub get_commentors_info{
	my ($self, $id, $format, $ref)=@_;
	goto e3 if ($ref);
	my $cos=$self->db->get_commentors_by_post($id);
	my @a;
	if (defined($cos)){
		foreach my $com ( @{$cos} ) {
			my $user = $self->db->get_user_info($com);
			unless (defined($user)){ 
				$user = $self->br->get_user_info($com);
				$self->db->insert_user($user);
			}
			push @a, $user;
		}
		return $self->se->to_jsona(\@a) if ($format eq 'json');
		return $self->se->to_jsonl(\@a) if ($format eq 'jsonl');
	}	
	e3:
	my ($post, $user, $coms)=$self->br->get_post_info($id);
	$self->db->insert_user($user);
	$self->db->insert_post($post);
	foreach my $com ( @{$coms} ) {
		$self->db->insert_commentor($com);
	}
	foreach my $com ( @{$coms} ) {
			my $user = $self->db->get_user_info($com->nik);
			unless (defined($user)){ 
				$user = $self->br->get_user_info($com->nik);
				$self->db->insert_user($user);
			}
			push @a, $user;
		}
	return $self->se->to_jsona(\@a) if ($format eq 'json');
	return $self->se->to_jsonl(\@a) if ($format eq 'jsonl');
}

sub get_post_info{
	my ($self, $id, $format, $ref)=@_;
	goto e4 if ($ref);
	my $inf=$self->db->get_post_info($id);
	return $self->se->to_json($inf) if (defined($inf));
	e4:
	my ($post, $user, $coms)=$self->br->get_post_info($id);
	$self->db->insert_user($user);
	$self->db->insert_post($post);
	foreach my $com ( @{$coms} ) {
		$self->db->insert_commentor($com);
	}
	return $self->se->to_json($post);
}

sub get_self_commentors{
	my ($self, $format)=@_;
	my $coms=$self->db->self_commentors;
	my @a;
	foreach my $com (@{$coms}){
		push @a, $self->get_user_info($com); #may be lack of args
	}

	#we get not structure but json
	my $out;
	if ($format eq 'json'){
		$out=join ',', @a;
		$out='[' . $out . ']'; 
	}
	if ($format eq 'jsonl'){
		$out=join "\n", @a;
	}
	return $out;
}

sub get_desert_posts{
	my ($self, $n, $format)=@_;
	my $a=$self->db->desert_posts($n);
	return $self->se->to_jsona($a) if ($format eq 'json');
	return $self->se->to_jsonl($a) if ($format eq 'jsonl');
}

1;
