package Local::Habr;

use strict;
use warnings;
use Local::Habr::Database;
use Local::Habr::Browser;
use Local::Habr::Serializer;
use Mouse;

has 'database' => (is => 'rw', builder => '_db'); 		#var to connect to database
has 'browser' => (is => 'rw', builder => '_br');		#var to connect to browser
has 'serializer' => (is => 'rw', builder => '_se');		#var to map data form oblect to strings

sub _db{ Local::Habr::Database->new; }

sub _br{ Local::Habr::Browser->new; }

sub _se{ Local::Habr::Serializer->new; }


# make wrappers for useful serialization and without lack of functionality
sub get_user_info{
	my ($self, $name, $for, $ref)=@_;
	my $r=$self->_get_user_info($name, $ref);
	return $self->serializer->serialize($self->_extr_data($r), $for);
}

sub get_user_info_by_post{
	my ($self, $id, $for, $ref)=@_;
	my $r=$self->_get_user_info_by_post($id, $ref);
	return $self->serializer->serialize($self->_extr_data($r), $for);
}

sub get_commentors_info{
	my ($self, $id, $for, $ref)=@_;
	my $r=$self->_get_commentors_info($id, $ref);
	return $self->serializer->serialize($self->_extr_data($r), $for);
}

sub get_post_info{
	my ($self, $id, $for, $ref)=@_;
	my $r=$self->_get_post_info($id, $ref);
	return $self->serializer->serialize($self->_extr_data($r), $for);
}
sub get_self_commentors{
	my ($self, $for)=@_;
	my $r=$self->_get_self_commentors;
	return $self->serializer->serialize($self->_extr_data($r), $for);
}

sub get_desert_posts{
	my ($self, $n, $for)=@_;
	my $r=$self->_get_desert_posts($n);
	return $self->serializer->serialize($self->_extr_data($r), $for);
}

############################################
# may be it would better to include similar methods in Post, User, Commentor
sub _extr_data{
	my ($self, $r)=@_;
	if (ref($r) eq 'ARRAY'){
		my @a;
		for my $v (@{$r}){
			my $h=%$v{'_column_data'};
			push @a, $h;
		}
		return \@a;
	}
	my $h=%$r{'_column_data'};
}

#######################################

sub _get_user_info{
	my ($self, $name, $ref)=@_;
	my $user;
	if (!$ref){
		$user=$self->database->get_user_info($name);
		return $user if (defined($user));
	}
	$user=$self->browser->get_user_info($name);
	$self->database->insert_user($user);
	return $user;
}

sub _get_user_info_by_post{
	my ($self, $id, $ref)=@_;
	my $pot=$self->database->get_post_info($id);
	if (!$ref){
		my $us;
		if (defined($pot)){
			$us=$self->database->get_user_info($pot->author);
			unless (defined($us)){
				$us=$self->browser->get_user_info($pot->author);
				$self->database->insert_user($us);
			}
			return $us;
		}
	}
	my ($post, $user, $coms)=$self->browser->get_post_info($id);
	$self->database->insert_user($user);
	$self->database->insert_post($post);
	foreach my $com ( @{$coms} ) {
		$self->database->insert_commentor($com);
	}
	return $user;
}

sub _get_commentors_info{
	my ($self, $id, $ref)=@_;
	my @a;
	if (!$ref){
		my $cos=$self->database->get_commentors_by_post($id);
		if (defined($cos)){
			foreach my $com ( @{$cos} ) {
				my $user = $self->database->get_user_info($com);
				unless (defined($user)){ 
					$user = $self->browser->get_user_info($com);
					$self->database->insert_user($user);
				}
				push @a, $user;
			}
			return \@a;
		}	
	}
	my ($post, $user, $coms)=$self->browser->get_post_info($id);
	$self->database->insert_user($user);
	$self->database->insert_post($post);
	foreach my $com ( @{$coms} ) {
		$self->database->insert_commentor($com);
	}
	foreach my $com ( @{$coms} ) {
		my $user = $self->database->get_user_info($com->nik);
		unless (defined($user)){ 
			$user = $self->browser->get_user_info($com->nik);
			$self->database->insert_user($user);
		}
		push @a, $user;
	}
	return \@a;
}

sub _get_post_info{
	my ($self, $id, $ref)=@_;
	if (!$ref){
		my $inf=$self->database->get_post_info($id);
		return $inf if (defined($inf));
	}
	my ($post, $user, $coms)=$self->browser->get_post_info($id);
	$self->database->insert_user($user);
	$self->database->insert_post($post);
	foreach my $com ( @{$coms} ) {
		$self->database->insert_commentor($com);
	}
	return $post;
}

sub _get_self_commentors{
	my ($self)=@_;
	my $coms=$self->database->self_commentors;
	my @a;
	foreach my $com (@{$coms}){
		push @a, $self->_get_user_info($com); #may be lack of args
	}
	return \@a;
}

sub _get_desert_posts{
	my ($self, $n)=@_;
	return $self->database->desert_posts($n);
}

1;
