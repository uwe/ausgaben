package Ausgaben::Schema::VerteilungPerson;

use namespace::autoclean;
use DBIx::Class::Candy;


table 'verteilung_person';

column verteilung_id => {data_type => 'INTEGER', is_nullable => 0};
column person_id     => {data_type => 'INTEGER', is_nullable => 0};
column anteil        => {data_type => 'INTEGER', is_nullable => 0};

primary_key qw/verteilung_id person_id/;

belongs_to qw/verteilung Ausgaben::Schema::Verteilung verteilung_id/;
belongs_to qw/person     Ausgaben::Schema::Person     person_id/;


1;
