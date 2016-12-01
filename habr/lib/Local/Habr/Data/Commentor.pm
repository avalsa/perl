package Local::Habr::Data::Commentor;

use strict;
use warnings;
use Mouse;

has 'nik' => 	(is => 'rw', required => 1);
has 'id_post' =>(is => 'rw', required => 1);

1;