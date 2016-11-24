package Local::Database;

use strict;
use warnings;
use Local::Schema;
use Local::Data::Post;
use Local::Data::User;
use Mouse;

has 'schema' => (is => 'rw', builder => '_sch');

sub _sch{
	return $a=Local::Schema->connect(
		'DBI:Pg:database=habr;host=localhost;port=5432',
	 	'postgres',
	 	'123456',
	 	{ RaiseError => 1 });
}

#POST

sub logger{
	my ($self, $str)=@_;
	print $str . "\n";
}

sub get_post_info{
	my ($self, $id)=@_;
	my $rs = $self->schema->resultset('PostDAO');
	my $post = $rs->find($id);
	return undef if (!defined($post)); 
	my %h = %$post;
	my $l=$h{'_column_data'};
	my $a= Local::Data::Post->new( $l );
}

sub insert_post{
	my ($self, $post)=@_;
	my %h = %$post;
 	my $res = $self->schema->resultset('PostDAO')->update_or_new(\%h);
 	$res->update_or_insert;
}

#################################

#USER

sub get_user_info{
	my ($self, $id)=@_;
	$self->logger("get_user_info_db_$id");
	my $rs = $self->schema->resultset('UserDAO');
	return undef if (!defined($id));
	my $user = $rs->find($id);
	return undef if (!defined($user));
	my %h = %$user;
	my $l=$h{'_column_data'};
	my $a= Local::Data::User->new( $l );
}

sub insert_user{
	my ($self, $user)=@_;
	$self->logger('insert_user');
	my %h = %$user;
 	my $res = $self->schema->resultset('UserDAO')->update_or_new(\%h);
 	$res->update_or_insert;
}

################################

#COMMENTOR

sub get_commentors_by_post{
	my ($self, $id)=@_;
	my $rs = $self->schema->resultset('CommentorDAO');
	my $rs2 = $rs->search({id_post => $id});
	my @a;
	while (my $user = $rs2->next) {
		push @a, $user->nik;
	}
	return undef if ($#a==-1);
	return \@a;
	#I dont know what in array (not data, but schema)
}

sub insert_commentor{
	my ($self, $commentor)=@_;
	$self->logger('insert_commentor');
	my %h = %$commentor;
	my $res = $self->schema->resultset('CommentorDAO')->update_or_new(\%h);
 	$res->update_or_insert;
}

#################################

#STATISTICS

sub self_commentors{
	my $self=shift;
	my $rs = $self->schema->resultset('PostDAO')->search({
		'me.author' => \'= commentors.nik',
	}, {	
			join => 'commentors'
     	});
	my @a;
	while(my $result = $rs->next) {
      	push @a, $result->get_column('author');
    }
    return \@a;
}

sub desert_posts{
	my ($self, $n)=@_;
 	my $rs = $self->schema->resultset('PostDAO')->search({
 		
 		}, {
 			join => 'commentors',
 			group_by => ['id'],
 			having => \[ 'count(commentors.nik) < ?', $n ]
 			});
 	my @a;
 	while (my $post = $rs->next) {
      	my %h = %$post;
		my $l=$h{'_column_data'};
		my $d= Local::Data::Post->new( $l );
		push @a, $d;
    }
    return \@a;
}

################################

1;
