package Local::Habr::Database;

use strict;
use warnings;
use Local::Habr::Schema;
use Local::Habr::Schema::Result::Post;
use Local::Habr::Schema::Result::User;
use Local::Habr::Schema::Result::Commentor;
use Config::Properties;
use Mouse;
use Log::Any '$log';
use Log::Any::Adapter ('Stdout');

has 'schema' => (is => 'rw', builder => '_sch');

sub _sch{	
	my $filename = 'config.properties';  #bad moment, may be it would better to get file path to config as param and keep config in src
	open my $fh, '<', $filename
    	or die "unable to open configuration file";

  	my $properties = Config::Properties->new();
  	$properties->load($fh);

  	my $db_driver = $properties->getProperty('db_driver');
  	my $db_name = $properties->getProperty('db_name');
  	my $db_host = $properties->getProperty('db_host');
  	my $db_port = $properties->getProperty('db_port');
  	my $db_user = $properties->getProperty('db_user');
  	my $db_pass = $properties->getProperty('db_pass');

  	return $a=Local::Habr::Schema->connect(
  		"$db_driver=$db_name;host=$db_host;port=$db_port",
	 	$db_user,
	 	$db_pass,
	 	{ RaiseError => 1 });
}

sub logger{
	my ($self, $str)=@_;
	$log->info($str);
}

#POST

sub get_post_info{
	my ($self, $id)=@_;
	my $rs = $self->schema->resultset('Post');
	$rs->find($id); 
}

sub insert_post{
	my ($self, $post)=@_;
	my %h = %$post;
 	my $res = $self->schema->resultset('Post')->update_or_new($h{'_column_data'});
 	$res->update_or_insert;
}

#################################

#USER

sub get_user_info{
	my ($self, $id)=@_;
	$self->logger("get_user_info_db_$id");
	my $rs = $self->schema->resultset('User');
	return undef if (!defined($id));
	$rs->find($id);
}

sub insert_user{
	my ($self, $user)=@_;
	$self->logger('insert_user');
	my %h = %$user;
 	my $res = $self->schema->resultset('User')->update_or_new($h{'_column_data'});
 	$res->update_or_insert;
}

################################

#COMMENTOR

sub get_commentors_by_post{
	my ($self, $id)=@_;
	my $rs = $self->schema->resultset('Commentor');
	my $rs2 = $rs->search({id_post => $id});
	my @a;
	while (my $user = $rs2->next) {
		push @a, $user->nik;
	}
	return undef if ($#a==-1);
	return \@a;
}

sub insert_commentor{
	my ($self, $commentor)=@_;
	$self->logger('insert_commentor');
	my %h = %$commentor;
	my $res = $self->schema->resultset('Commentor')->update_or_new($h{'_column_data'});
 	$res->update_or_insert;
}

#################################

#STATISTICS

sub self_commentors{
	my $self=shift;
	my $rs = $self->schema->resultset('Post')->search({
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
 	my $rs = $self->schema->resultset('Post')->search({
 		
 		}, {
 			join => 'commentors',
 			group_by => ['id'],
 			having => \[ 'count(commentors.nik) < ?', $n ]
 			});
 	my @a;
 	while (my $post = $rs->next) {
      	push @a, $post;
    }
    return \@a;
}

################################

1;
