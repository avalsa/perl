package main;
use strict;
use warnings;
use feature 'say';

use Local::Reducer::MaxDiff;
use Local::Reducer::Sum;
use Local::Source::Array;
use Local::Source::Text;
use Local::Row::Simple;
use Local::Row::JSON;
# my $a=Local::Reducer::Sum->new(x=>5);
# print $a->fo;

# my $ar=[2,3,4,5, "gvh", 7, 8];
# my $b=Local::Source::Array->new(array=>$ar);
# while (defined (my $x=$b->next)){
#    say $x;
# }

# my $str="we \n er \n wewewewe\n w e rtrt   er";
# my $b=Local::Source::Text->new(text=>$str);
# while (defined (my $x=$b->next)){
#    say $x;
# }

# my $str="sended:1024,received:2048";
# my $x=Local::Row::Simple->new(str=>$str);
# say $x->get("sended", 12);
# say $x->get("received", 12);
# say $x->get("got", 12);

# my $str="{\"sended\":1024,\"received\":2048}";
# my $x=Local::Row::JSON->new(str=>$str);
# say $x->get("sended", 12);
# say $x->get("received", 12);
# say $x->get("got", 12);

# my $reducer = Local::Reducer::Sum->new(
#     field => 'price',
#     source => Local::Source::Array->new(array => [
#         '{"price": 1}',
#         '{"price": 2}',
#         '{"price": 3}',
#     ]),
#     row_class => 'Local::Row::JSON',
#     initial_value => 0,
# );

# say "main" . $reducer->reduce_n(1);
# say "main" . $reducer->reduce_all();

# my $reducer = Local::Reducer::MaxDiff->new(
#     top => 'received',
#     bottom => 'sended',
#     source => Local::Source::Text->new(text =>"sended:1024,received:2048\nsended:2048,received:10240"),
#     row_class => 'Local::Row::Simple',
#     initial_value => 0,
# );
# say "main" . $reducer->reduce_n(1);
# say "main" . $reducer->reduce_all();