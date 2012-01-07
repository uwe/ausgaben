package Ausgaben::Schema::Betrag;

use namespace::autoclean;
use DBIx::Class::Candy;


table 'betrag';

column buchung_id => {data_type => 'INTEGER', is_nullable => 0};
column konto_id   => {data_type => 'INTEGER', is_nullable => 0};
column betrag     => {data_type => 'INTEGER', is_nullable => 0};

primary_key qw/buchung_id konto_id/;

belongs_to qw/buchung Ausgaben::Schema::Buchung buchung_id/;
belongs_to qw/konto   Ausgaben::Schema::Konto   konto_id/;


1;
