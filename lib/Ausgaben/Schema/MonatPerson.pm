package Ausgaben::Schema::MonatPerson;

use namespace::autoclean;
use DBIx::Class::Candy -components => [qw/InflateColumn::DateTime/];


table 'monat_person';

column datum            => {data_type => 'DATE',    is_nullable => 0};
column person_id        => {data_type => 'INTEGER', is_nullable => 0};
column gesamt           => {data_type => 'INTEGER', is_nullable => 0};
column ignoriert        => {data_type => 'INTEGER', is_nullable => 0};
column jaehrlich        => {data_type => 'INTEGER', is_nullable => 0};
column anteil_gesamt    => {data_type => 'INTEGER', is_nullable => 0};
column anteil_ignoriert => {data_type => 'INTEGER', is_nullable => 0};
column anteil_jaehrlich => {data_type => 'INTEGER', is_nullable => 0};

primary_key qw/datum person_id/;

belongs_to qw/person Ausgaben::Schema::Person person_id/;


1;
