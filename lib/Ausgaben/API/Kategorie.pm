package Ausgaben::API::Kategorie;

use namespace::clean;
use Moose;

use Carp qw(croak);


sub kategorie_neu {
    my ($self, %arg) = @_;

    my $name = delete $arg{name} || croak 'NAME fehlt';

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    return $self->rs('Kategorie')->create({name => $name});
}


1;
