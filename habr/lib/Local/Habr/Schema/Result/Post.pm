use utf8;
package Local::Habr::Schema::Result::Post;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("posts");

__PACKAGE__->add_columns(
	
  "id",
  { data_type => "integer", is_nullable => 0 },
  
  "stars",
  { data_type => "integer", is_nullable => 0 },

  "views",
  { data_type => "integer", is_nullable => 0 },

  "ranking",
  { data_type => "integer", is_nullable => 0 },

  "author",
  { data_type => "varchar(30)", is_nullable => 0 },

  "title",
  { data_type => "varchar(100)", is_nullable => 0 },
  
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(commentors => 'Local::Habr::Schema::Result::Commentor', 'id_post');
1;
