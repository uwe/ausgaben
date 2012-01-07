package Ausgaben::Schema::MonatKonto;

use namespace::autoclean;
use DBIx::Class::Candy -components => [qw/InflateColumn::DateTime/];


table 'monat_konto';

column datum     => {data_type => 'DATE',    is_nullable => 0};
column konto_id  => {data_type => 'INTEGER', is_nullable => 0};
column gesamt    => {data_type => 'INTEGER', is_nullable => 0};
column ignoriert => {data_type => 'INTEGER', is_nullable => 0};
column jaehrlich => {data_type => 'INTEGER', is_nullable => 0};

primary_key qw/datum konto_id/;

belongs_to qw/konto Ausgaben::Schema::Konto konto_id/;


1;
