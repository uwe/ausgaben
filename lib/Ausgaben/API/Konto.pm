package Ausgaben::API::Konto;

use namespace::autoclean;
use Moose;

use Carp qw(croak);
use Data::Dumper;


sub konto_neu {
    my ($self, %arg) = @_;

    my %k = (
             name           => delete $arg{name}           || croak('NAME fehlt'),
             reihenfolge    => delete $arg{reihenfolge}    || 0,
             anfangsbestand => delete $arg{anfangsbestand} || 0,
             verteilung_id  => delete $arg{verteilung}     || croak('VERTEILUNG fehlt'),
            );

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    return $self->rs('Konto')->create(\%k);
}

# berechnet den Anfangsbestand aller Konten fuer einen Monat
sub konto_anfangsbestand {
    my ($self, %arg) = @_;

    my $datum = delete $arg{datum} or croak 'DATUM fehlt';
    $datum = $self->_monat($datum) or croak 'DATUM falsch';


    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    my %konto = map { $_->id => $_->anfangsbestand + 0 } $self->rs('Konto')->all;

    my @monat = $self->rs('MonatKonto')->search
        (
         {
          datum => {'<' => $datum->ymd('-')},
         },
         {
          select   => ['konto_id', {sum => 'gesamt'}],
          as       => ['konto_id', 'gesamt'],
          group_by => ['konto_id'],
         },
        );
    foreach my $monat (@monat) {
        $konto{$monat->konto_id} += $monat->gesamt;
    }

    return \%konto;
}


1;
