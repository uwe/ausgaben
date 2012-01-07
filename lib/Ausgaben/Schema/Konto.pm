package Ausgaben::Schema::Konto;

use namespace::autoclean;
use DBIx::Class::Candy -components => [qw/Ordered/];


__PACKAGE__->position_column(qw/reihenfolge/);


table 'konto';

column id             => {data_type => 'INTEGER', is_nullable => 0};
column name           => {data_type => 'VARCHAR', is_nullable => 0};
column reihenfolge    => {data_type => 'INTEGER', is_nullable => 0};
column anfangsbestand => {data_type => 'INTEGER', is_nullable => 0};
column verteilung_id  => {data_type => 'INTEGER', is_nullable => 0};
column anzeigen       => {data_type => 'INTEGER', is_nullable => 0};

primary_key 'id';

belongs_to qw/verteilung Ausgaben::Schema::Verteilung verteilung_id/;


1;
