package Ausgaben::Schema::Buchung;

use namespace::autoclean;
use DBIx::Class::Candy -components => [qw/InflateColumn::DateTime Ordered/];


__PACKAGE__->position_column(qw/reihenfolge/);
__PACKAGE__->grouping_column(qw/datum/);


table 'buchung';

column id            => {data_type => 'INTEGER', is_nullable => 0};
column datum         => {data_type => 'DATE',    is_nullable => 0};
column kategorie_id  => {data_type => 'INTEGER', is_nullable => 1};
column haendler_id   => {data_type => 'INTEGER', is_nullable => 1};
column verteilung_id => {data_type => 'INTEGER', is_nullable => 0};
column ignorieren    => {data_type => 'INTEGER', is_nullable => 0};
column jaehrlich     => {data_type => 'INTEGER', is_nullable => 0};
column bemerkung     => {data_type => 'VARCHAR', is_nullable => 1};
column reihenfolge   => {data_type => 'INTEGER', is_nullable => 0};

primary_key 'id';

belongs_to qw/kategorie  Ausgaben::Schema::Kategorie  kategorie_id/;
belongs_to qw/haendler   Ausgaben::Schema::Haendler   haendler_id/;
belongs_to qw/verteilung Ausgaben::Schema::Verteilung verteilung_id/;
has_many   qw/betraege   Ausgaben::Schema::Betrag     buchung_id/;


1;
