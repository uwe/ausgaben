package Ausgaben::API::Person;

use namespace::clean;
use Moose;

use Carp qw(croak);


sub person_neu {
    my ($self, %arg) = @_;

    my $name = delete $arg{name} || croak 'NAME fehlt';

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    return $self->rs('Person')->create({name => $name});
}


1;
