use utf8;
package Local::Habr::Browser;

use strict;
use warnings;
use Mojo::DOM;
use LWP 5.64;
use Encode qw(decode);
use Local::Habr::Schema::Result::Post;
use Local::Habr::Schema::Result::User;
use Local::Habr::Schema::Result::Commentor;
use Mouse;

sub get_post_info{
	my ($self, $id)=@_;
	my $browser=LWP::UserAgent->new;
	my $response = $browser->get( 'https://habrahabr.ru/post/' . $id );
  	die "Can't get $self->url -- ", $response->status_line
   	unless $response->is_success;
 	my $str=$response->content;

 	my $dom = Mojo::DOM->new($str);

 	#GET POST INFO 

 	my ($title, $nik, $stars, $ranking, $views);
 
 	$title = $dom->at('title')->text;
 
	for my $e ($dom->find('a')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'author-info__nickname'){ $nik=$e->text; last;}
	}
	
	for my $e ($dom->find('div')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'views-count_post'){ $views=$e->text; last;}
		
	}

	for my $e ($dom->find('span')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'favorite-wjt__counter js-favs_count'){ $stars=$e->text;}
		if ($t eq 'voting-wjt__counter-score js-score'){ $ranking=$e->text;}
		last if (defined($stars) and defined($ranking));
	}
	die "Bad post" if (!defined($stars) or !defined($ranking) or !defined($views) or !defined($title) or !defined($nik) );
	$nik=substr($nik, 1, length($nik));
	$title=decode('UTF8', $title);
	$ranking=decode('UTF8', $ranking);
	$views =~ tr/,/./;
	if ($views =~ m/(.+)k/){
		$views = $1 * 1000;
	}
	my $post=Local::Habr::Schema::Result::Post->new({id=>$id, title => $title, stars => $stars, views => $views, ranking => $ranking, author => $nik});


	###########################

	#GET COMMENTORS INFO

	my @coms;

	for my $e ($dom->find('a')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'comment-item__username'){ push @coms, Local::Habr::Schema::Result::Commentor->new({id_post => $id, nik => $e->text});}
	}

	#############################

	#GET AUTHOR INFO

	#we have $nik
	my ($karma, $rank);
	for my $e ($dom->find('div')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'voting-wjt__counter-score js-karma_num'){ $karma=$e->text;  }
		if ($t eq 'statistic__value statistic__value_magenta'){ $rank=$e->text;}
		last if (defined($karma) and defined($rank));
	}
	$karma=decode('UTF8', $karma);
	$rank=decode('UTF8', $rank);
	$karma =~ tr/,/./;
	$rank =~ tr/,/./;
	my $user=Local::Habr::Schema::Result::User->new({nik => $nik, karma => $karma, ranking => $rank});
	die "Bad user" if (!defined($nik) or !defined($rank) or !defined($karma));
	##############################

	#SEND ALL INFO (TAKE WHAT YOU NEED)
	return $post, $user, \@coms;
}

sub get_user_info{
	my ($self, $id)=@_;
	my $browser=LWP::UserAgent->new;
	my $response = $browser->get( 'https://habrahabr.ru/users/' . $id );
  	die "Can't get $self->url -- ", $response->status_line
   	unless $response->is_success;
 	my $str=$response->content;

 	my $dom = Mojo::DOM->new($str);
 	my ($nik, $karma, $ranking);

	for my $e ($dom->find('a')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'author-info__nickname'){ $nik=$e->text; last;}
	}

	for my $e ($dom->find('div')->each){
		my $t= $e->attr('class');
		next if (!defined($t));
		if ($t eq 'voting-wjt__counter-score js-karma_num'){ $karma=$e->text;}
		if ($t eq 'statistic__value statistic__value_magenta'){ $ranking=$e->text;}
		last if (defined($karma) and defined($ranking));
	}
	die "Bad user $id" if (!defined($nik) or !defined($ranking) or !defined($karma));
	$nik=substr($nik, 1, length($nik));
	$karma=decode('UTF8', $karma);
	$ranking=decode('UTF8', $ranking);
	$karma =~ tr/,/./;
	$ranking =~ tr/,/./;
	my $user=Local::Habr::Schema::Result::User->new({nik => $nik, karma => $karma, ranking => $ranking});
}

1;
