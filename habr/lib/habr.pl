#!/usr/bin/env perl
use strict;
use Local::Habr;
use DDP;
use feature 'say';
use Getopt::Long;
use Data::Dumper;
use Switch;
use utf8;

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
print Dumper [$n, $name, $id, $post, $for, $ref, $goal];
my $h=Local::Habr->new;
die "Such format not supported" if ($for ne 'json' and $for ne 'jsonl'); 

switch ($goal){
	case 'user' 			{ say $h->get_user_info($name) if defined($name); 
							  say $h->$h->get_user_info_by_post($post) if defined($post); }
	case 'commenters' 		{ say $h->get_commentors_info($post, $for) if defined($post); }
	case 'post' 			{ say $h->get_post_info($id) if defined($id); }
	case 'self_commentors' 	{ say $h->get_self_commentors($for); }
	case 'desert_posts' 	{ say $h->get_desert_posts($n, $for) if defined($n); }
	else 					{ die "Bad goal"; }
}

#all ok but add refresh


 # my $a=$h->get_user_info('Obramko');
 # p $a;

# my $b=$h->get_user_info_by_post(315658); 
# p $b;

#2 ITEMS DONE !!!!!!!!!!!!!!!!!

# my $c=$h->get_commentors_info(315658, 'jsonl'); #all 2 form 
# p $c;

#3 Items DONE!!!!!!!!!!!!!!!!!!

# my $d=$h->get_post_info(315576);
# p $d;

#4 ITEMS DONE !!!!!!!!!
#MAIN WORK IS DONE? YEEEE.

# my $e=$h->get_self_commentors('jsonl');  #all 2 form
# p $e;

#Last one LEFT

# my $f=$h->get_desert_posts(2, 'jsonl');  #all 2 form
# p $f;

#ALL IDEA DONE