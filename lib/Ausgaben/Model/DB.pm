package Ausgaben::Model::DB;

use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::DBIC::Schema';


__PACKAGE__->config(schema_class => 'Ausgaben::Schema',
                    connect_info => {dsn      => 'dbi:mysql:ausgaben',
                                     user     => 'ausgaben',
                                     password => 'ausgaben',
                                    },
                   );


__PACKAGE__->meta->make_immutable;

1;
