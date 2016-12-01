#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib/";

use strict;
use warnings;
no warnings 'experimental';
use Local::Habr;
use feature qw/switch say/;
use Getopt::Long;

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

given ($goal){
	when ('user') 			{ say $h->get_user_info($name, $for, $ref) if defined($name); 
							  say $h->get_user_info_by_post($post, $for, $ref) if defined($post); }
	when ('commenters')		{ say $h->get_commentors_info($post, $for, $ref) if defined($post); }
	when ('post') 			{ say $h->get_post_info($id, $for, $ref) if defined($id); }
	when ('self_commentors'){ say $h->get_self_commentors($for); }
	when ('desert_posts') 	{ say $h->get_desert_posts($n, $for) if defined($n); }
	default 				{ die "Bad goal"; }
}
