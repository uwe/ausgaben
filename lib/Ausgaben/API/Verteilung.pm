package Ausgaben::API::Verteilung;

use namespace::clean;
use Moose;

use Carp qw(croak);


sub verteilung_neu {
    my ($self, %arg) = @_;

    my $name   = delete $arg{name}   || croak 'NAME fehlt';
    my $person = delete $arg{person} || croak 'PERSON fehlt';

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    my $gesamt   = 0;
    my @personen = ();
    while (my ($id, $anteil) = each %$person) {
        push @personen, {person_id => $id, anteil => $anteil};
        $gesamt += $anteil;
    }

    return $self->rs('Verteilung')->create
        ({
          name                => $name,
          anteil_gesamt       => $gesamt,
          verteilung_personen => \@personen,
         });
}


1;
