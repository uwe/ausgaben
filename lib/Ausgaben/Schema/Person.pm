package Ausgaben::Schema::Person;

use namespace::autoclean;
use DBIx::Class::Candy;


table 'person';

column id   => {data_type => 'INTEGER', is_nullable => 0};
column name => {data_type => 'VARCHAR', is_nullable => 0};

primary_key 'id';

has_many qw/verteilung_person Ausgaben::Schema::VerteilungPerson person_id/;

many_to_many qw/verteilungen verteilung_person verteilung_id/;


1;
