use utf8;
package Local::Schema::Result::CommentorDAO;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("commentors");

__PACKAGE__->add_columns(
	
  "id_post",
  { data_type => "integer", is_nullable => 0 },

  "nik",
  { data_type => "varchar(30)", is_nullable => 0 }
  
);

__PACKAGE__->set_primary_key("nik");
__PACKAGE__->belongs_to(post => 'Local::Schema::Result::PostDAO', 'id_post');
1;
