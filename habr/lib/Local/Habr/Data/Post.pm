package Local::Habr::Data::Post;

use strict;
use warnings;
use Mouse;

has 'id' => 	(is => 'rw', required => 1);
has 'title' => 	(is => 'rw', required => 1);
has 'author' => (is => 'rw', required => 1);
has 'views' => 	(is => 'rw', required => 1);
has 'stars' => 	(is => 'rw', required => 1);
has 'ranking' =>(is => 'rw', required => 1);

1;
