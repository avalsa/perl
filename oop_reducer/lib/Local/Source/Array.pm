package Local::Source::Array;

use strict;
use warnings;
use Mouse;

extends 'Local::Source';

has 'array' => (is => 'rw', required => 1);

1;