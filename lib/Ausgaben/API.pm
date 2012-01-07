package Ausgaben::API;

use Moose;
extends qw(Ausgaben::API::Buchung
           Ausgaben::API::Haendler
           Ausgaben::API::Kategorie
           Ausgaben::API::Konto
           Ausgaben::API::Monat
           Ausgaben::API::Person
           Ausgaben::API::Verteilung
         );

use DateTime;


has schema => (is => 'ro', required => 1);


sub rs {
    return (shift)->schema->resultset('Ausgaben::Schema::'.shift);
}


# liefert DateTime-Objekt zurueck (oder undef), Tag ist immer 1
sub _monat {
    my ($self, $datum) = @_;

    return $datum->clone->set(day => 1) if ref $datum;

    if ($datum =~ /^(\d\d\d\d)-(\d\d)/) {
        return eval { DateTime->new(year => $1, month => $2, day => 1) };
    }

    return;
}


1;
