package Ausgaben::Schema::Verteilung;

use namespace::autoclean;
use DBIx::Class::Candy;


table 'verteilung';

column id            => {data_type => 'INTEGER', is_nullable => 0};
column name          => {data_type => 'VARCHAR', is_nullable => 0};
column anteil_gesamt => {data_type => 'INTEGER', is_nullable => 0};

primary_key 'id';

has_many qw/verteilung_personen Ausgaben::Schema::VerteilungPerson verteilung_id/;

many_to_many qw/personen verteilung_personen person_id/;


1;
