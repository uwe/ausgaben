package Ausgaben::API::Buchung;

use namespace::autoclean;
use Moose;

use Carp qw(croak);


sub buchung_neu {
    my ($self, %arg) = @_;

    my $datum = delete $arg{datum} || croak 'DATUM fehlt';
    my $konto = delete $arg{konto} || croak 'KONTO fehlt';

    my %b = (
             kategorie_id  => delete $arg{kategorie}  || undef,
             haendler_id   => delete $arg{haendler}   || undef,
             verteilung_id => delete $arg{verteilung} || croak('VERTEILUNG fehlt'),
             ignorieren    => delete $arg{ignorieren} || 0,
             jaehrlich     => delete $arg{jaehrlich}  || 0,
             bemerkung     => delete $arg{bemerkung}  || '',
            );

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    # niemals gleichzeitig jaehrlich und ignorieren
    $b{jaehrlich} = 0 if $b{ignorieren};

    # DateTime-Objekt?
    $b{datum} = ref $datum ? $datum->ymd('-') : $datum;

    my @betraege = ();
    while (my ($konto_id, $betrag) = each %$konto) {
        push @betraege, {konto_id => $konto_id, betrag => $betrag};
    }
    $b{betraege} = \@betraege;

    my $buchung = $self->rs('Buchung')->create(\%b);
    return unless $buchung;

    # Monat neu berechnen
    $self->monat_berechne(datum => $datum);

    return $buchung;
}

sub buchung_edit {
    my ($self, %arg) = @_;

    my $id    = delete $arg{id}    || croak 'ID fehlt';
    my $datum = delete $arg{datum} || croak 'DATUM fehlt';
    my $konto = delete $arg{konto} || croak 'KONTO fehlt';

    my %b = (
             kategorie_id  => delete $arg{kategorie}  || undef,
             haendler_id   => delete $arg{haendler}   || undef,
             verteilung_id => delete $arg{verteilung} || croak('VERTEILUNG fehlt'),
             ignorieren    => delete $arg{ignorieren} || 0,
             jaehrlich     => delete $arg{jaehrlich}  || 0,
             bemerkung     => delete $arg{bemerkung}  || '',
            );

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    # niemals gleichzeitig jaehrlich und ignorieren
    $b{jaehrlich} = 0 if $b{ignorieren};

    # DateTime-Objekt?
    $b{datum} = ref $datum ? $datum->ymd('-') : $datum;

    # Betraege loeschen und neu eintragen
    $self->rs('Betrag')->search({buchung_id => $id})->delete;
    while (my ($konto_id, $betrag) = each %$konto) {
        $self->rs('Betrag')->create({buchung_id => $id,
                                     konto_id   => $konto_id,
                                     betrag     => $betrag,
                                    });
    }

    my $buchung = $self->rs('Buchung')->find($id);

    # altes Datum merken
    my $datum_alt = $buchung->datum->ymd('-');

    while (my ($name, $value) = each %b) {
        $buchung->$name($value);
    }
    $buchung->update;


    # Monat neu berechnen
    $self->monat_berechne(datum => $datum);

    # alten Monat auch neu berechnen?
    my @datum     = split /-/, $datum;
    my @datum_alt = split /-/, $datum_alt;
    if ($datum[0] != $datum_alt[0] or $datum[1] != $datum_alt[1]) {
        $self->monat_berechne(datum => $datum_alt);
    }

    return $buchung;
}


1;
