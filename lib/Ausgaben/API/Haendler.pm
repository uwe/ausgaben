package Ausgaben::API::Haendler;

use namespace::clean;
use Moose;

use Carp qw(croak);


sub haendler_neu {
    my ($self, %arg) = @_;

    my $name = delete $arg{name} || croak 'NAME fehlt';

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    return $self->rs('Haendler')->create({name => $name});
}


1;
