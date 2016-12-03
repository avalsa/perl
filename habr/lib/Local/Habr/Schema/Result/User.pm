use utf8;
package Local::Habr::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("users");

__PACKAGE__->add_columns(
	
  "karma",
  { data_type => "varchar(10)", is_nullable => 0 },

  "ranking",
  { data_type => "varchar(10)", is_nullable => 0 },

  "nik",
  { data_type => "varchar(30)", is_nullable => 0 }
  
);

__PACKAGE__->set_primary_key("nik");

1;
