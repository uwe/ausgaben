package Ausgaben::Schema::MonatKategorie;

use namespace::autoclean;
use DBIx::Class::Candy -components => [qw/InflateColumn::DateTime/];


table 'monat_kategorie';

column datum        => {data_type => 'DATE',    is_nullable => 0};
column kategorie_id => {data_type => 'INTEGER', is_nullable => 0};
column gesamt       => {data_type => 'INTEGER', is_nullable => 0};
column ignoriert    => {data_type => 'INTEGER', is_nullable => 0};
column jaehrlich    => {data_type => 'INTEGER', is_nullable => 0};

primary_key qw/datum kategorie_id/;

belongs_to qw/kategorie Ausgaben::Schema::Kategorie kategorie_id/;


1;
