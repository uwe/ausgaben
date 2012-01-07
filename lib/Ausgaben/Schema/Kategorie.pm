package Ausgaben::Schema::Kategorie;

use namespace::autoclean;
use DBIx::Class::Candy;


table 'kategorie';

column id   => {data_type => 'INTEGER', is_nullable => 0};
column name => {data_type => 'VARCHAR', is_nullable => 0};

primary_key 'id';

has_many qw/buchungen Ausgaben::Schema::Buchung kategorie_id/;


1;
