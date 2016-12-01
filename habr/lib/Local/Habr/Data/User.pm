package Local::Habr::Data::User;

use strict;
use warnings;
use Mouse;

has 'nik' => 	(is => 'rw', required => 1);
has 'karma' => 	(is => 'rw', required => 1);
has 'ranking' =>(is => 'rw', required => 1);

1;