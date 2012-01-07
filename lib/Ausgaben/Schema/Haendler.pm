package Ausgaben::Schema::Haendler;

use namespace::autoclean;
use DBIx::Class::Candy;


table 'haendler';

column id   => {data_type => 'INTEGER', is_nullable => 0};
column name => {data_type => 'VARCHAR', is_nullable => 0};

primary_key 'id';

has_many qw/buchungen Ausgaben::Schema::Buchung haendler_id/;


1;
