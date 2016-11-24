#!/usr/bin/env perl


use FindBin;
use lib "$FindBin::Bin/../lib/";

use strict;
use warnings;
use Local::Habr;
use DDP;
use feature 'say';
use Getopt::Long;
use Data::Dumper;
use Switch;

my ($n, $name, $id, $post, $for, $ref);

GetOptions(
	"name=s" => \$name,
	"post=i" => \$post,
	"id=i" => \$id,
	"n=i" => \$n,
	"format=s" => \$for,
	"refresh" => \$ref,
);
my $goal=pop @ARGV;

my $h=Local::Habr->new;
die "Such format not supported" if ($for ne 'json' and $for ne 'jsonl'); 

switch ($goal){
	case 'user' 			{ say $h->get_user_info($name, $for, $ref) if defined($name); 
							  say $h->get_user_info_by_post($post, $for, $ref) if defined($post); }
	case 'commenters' 		{ say $h->get_commentors_info($post, $for, $ref) if defined($post); }
	case 'post' 			{ say $h->get_post_info($id, $for, $ref) if defined($id); }
	case 'self_commentors' 	{ say $h->get_self_commentors($for); }
	case 'desert_posts' 	{ say $h->get_desert_posts($n, $for) if defined($n); }
	else 					{ die "Bad goal"; }
}
