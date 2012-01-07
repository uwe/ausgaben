package Ausgaben::Schema::MonatHaendler;

use namespace::autoclean;
use DBIx::Class::Candy -components => [qw/InflateColumn::DateTime/];


table 'monat_haendler';

column datum       => {data_type => 'DATE',    is_nullable => 0};
column haendler_id => {data_type => 'INTEGER', is_nullable => 0};
column gesamt      => {data_type => 'INTEGER', is_nullable => 0};
column ignoriert   => {data_type => 'INTEGER', is_nullable => 0};
column jaehrlich   => {data_type => 'INTEGER', is_nullable => 0};

primary_key qw/datum haendler_id/;

belongs_to qw/haendler Ausgaben::Schema::Haendler haendler_id/;


1;
