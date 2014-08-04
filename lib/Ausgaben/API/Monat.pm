package Ausgaben::API::Monat;

use namespace::autoclean;
use Moose;

use Carp qw(croak);
use DateTime;


# bestimme Gesamtausgaben pro Monat
sub monat_ausgaben {
    my ($self, %arg) = @_;

    my $datum = delete $arg{datum} or croak 'DATUM fehlt';
    $datum = $self->_monat($datum) or croak 'DATUM falsch';

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    my %data = ();

    # Ausgaben pro Monat
    my @mk = $self->rs('MonatKonto')->search({datum => $datum->ymd('-')});
    foreach (@mk) {
        $data{ausgaben} += $_->gesamt - $_->ignoriert - $_->jaehrlich;
    }

    # jaehrliche Ausgaben des letzten Jahres addieren
    $self->schema->storage->dbh_do(
        sub {
            my ($storage, $dbh) = @_;
            my $end = $datum->clone->subtract(years => 1);
            my $sql = '
SELECT SUM(jaehrlich)
FROM monat_konto
WHERE datum <= ? AND datum > ?
';
            my ($jaehrlich) = $dbh->selectrow_array($sql, {},
                $datum->ymd('-'), $end->ymd('-'),
            );

            if ($jaehrlich) {
                $data{ausgaben}  += int($jaehrlich / 12);
                $data{jaehrlich} += int($jaehrlich / 12);
            }
        },
    );


    # Anteile pro Person
    my @mp = $self->rs('MonatPerson')->search({datum => $datum->ymd('-')});
    foreach (@mp) {
        $data{person}{$_->person_id} += $_->gesamt
            - $_->ignoriert
            - $_->jaehrlich;
        $data{anteil}{$_->person_id} += $_->anteil_gesamt
            - $_->anteil_ignoriert
            - $_->anteil_jaehrlich;
    }

    # jaehrliche Ausgaben des letzten Jahres addieren (pro Person)
    $self->schema->storage->dbh_do(
        sub {
            my ($storage, $dbh) = @_;
            my $end = $datum->clone->subtract(years => 1);
            my $sql = '
SELECT person_id, SUM(jaehrlich), SUM(anteil_jaehrlich)
FROM monat_person
WHERE datum <= ? AND datum > ?
GROUP BY person_id
';
            my $data = $dbh->selectall_arrayref($sql, {},
                $datum->ymd('-'), $end->ymd('-'),
            );
            foreach (@$data) {
                $data{person}{$_->[0]} += int($_->[1] / 12);
                $data{anteil}{$_->[0]} += int($_->[2] / 12);
            }
        },
    );

    return \%data;
}

# bestimme Gesamtausgaben fuer mehrere Monate
sub monat_ausgaben_range {
    my ($self, %arg) = @_;

    my $von  = delete $arg{von} or croak 'VON fehlt';
    my $bis  = delete $arg{bis} or croak 'BIS fehlt';
    my $skip = delete $arg{skip};

    $von = $self->_monat($von) or croak 'VON falsch';
    $bis = $self->_monat($bis) or croak 'BIS falsch';
    croak 'VON/BIS falsch' if $von > $bis;

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    my @ausgaben = ();
    while ($von <= $bis) {
        my $data = $self->monat_ausgaben(datum => $von);

        if ($data->{ausgaben} or not $skip) {
            # Datum ergaenzen
            $data->{datum} = $von->clone;
            push @ausgaben, $data;
        }

        $von->add(months => 1);
    }

    return \@ausgaben;
}

# berechne Monatssummen (nach jeder Aenderung aufrufen)
sub monat_berechne {
    my ($self, %arg) = @_;

    my $datum = delete $arg{datum} or croak 'DATUM fehlt';
    $datum = $self->_monat($datum) or croak 'DATUM falsch';

    croak 'Unbekannte Parameter: '.join(', ', keys %arg) if %arg;


    my @person_ids = map { $_->id } $self->rs('Person')->all;
    my %verteilung = ();
    foreach my $verteilung ($self->rs('Verteilung')->all) {
        my %data = (_ => $verteilung->anteil_gesamt);
        foreach ($verteilung->verteilung_personen) {
            $data{$_->person_id} = $_->anteil;
        }
        $verteilung{$verteilung->id} = \%data;
    }


    # Monatsende berechnen
    my $ende = $datum->clone->add(months => 1)->subtract(days => 1);

    # lade alle Buchungen dieses Monats
    my @buchungen = $self->rs('Buchung')
        ->search({datum => {-between => [$datum->ymd('-'),
                                         $ende->ymd('-'),
                                        ],
                           },
                 },
                )->all;

    my %konto     = ();
    my %person    = ();
    my %anteil    = ();
    my %haendler  = ();
    my %kategorie = ();
    foreach my $buchung (@buchungen) {
        # Buchung bestimmt anteilige Verteilung
        my $vert_anteil = $buchung->verteilung_id;

        foreach my $betrag ($buchung->betraege) {
            # Konto, Haendler und Kategorie aktualisieren
            _add(\%konto,     $betrag->konto_id,      $betrag->betrag, $buchung);
            _add(\%haendler,  $buchung->haendler_id,  $betrag->betrag, $buchung);
            _add(\%kategorie, $buchung->kategorie_id, $betrag->betrag, $buchung);

            # Konto bestimmt tatsaechliche Verteilung
            my $vert_betrag = $betrag->konto->verteilung_id;

            foreach my $id (@person_ids) {
                _add(\%person, $id, $betrag->betrag
                     * ($verteilung{$vert_betrag}{$id} || 0)
                     / $verteilung{$vert_betrag}{_},
                     $buchung);
                _add(\%anteil, $id, $betrag->betrag
                     * ($verteilung{$vert_anteil}{$id} || 0)
                     / $verteilung{$vert_anteil}{_},
                     $buchung);
            }
        }
    }

    # speichere Daten - Konten, Haendler, Kategorien
    my @data = ([Konto     => MonatKonto     => konto_id     => \%konto],
                [Haendler  => MonatHaendler  => haendler_id  => \%haendler],
                [Kategorie => MonatKategorie => kategorie_id => \%kategorie],
               );

    foreach my $data (@data) {
        my ($name, $class, $field, $hash) = @$data;
        foreach my $obj ($self->rs($name)->all) {
            my $id = $obj->id;
            $self->rs($class)
                ->update_or_create({datum     => $datum->ymd('-'),
                                    $field    => $id,
                                    gesamt    => $hash->{$id}{gesamt}    || 0,
                                    ignoriert => $hash->{$id}{ignoriert} || 0,
                                    jaehrlich => $hash->{$id}{jaehrlich} || 0,
                                   });
        }
    }

    # speichere Daten - Personen
    foreach my $id (@person_ids) {
        $self->rs('MonatPerson')
            ->update_or_create({datum            => $datum->ymd('-'),
                                person_id        => $id,
                                gesamt           => $person{$id}{gesamt}    || 0,
                                ignoriert        => $person{$id}{ignoriert} || 0,
                                jaehrlich        => $person{$id}{jaehrlich} || 0,
                                anteil_gesamt    => $anteil{$id}{gesamt}    || 0,
                                anteil_ignoriert => $anteil{$id}{ignoriert} || 0,
                                anteil_jaehrlich => $anteil{$id}{jaehrlich} || 0,
                               });
    }
}

sub _add {
    my ($hash, $id, $betrag, $buchung) = @_;

    $id ||= 0;

    $hash->{$id}{gesamt}    += $betrag;
    $hash->{$id}{ignoriert} += $betrag if $buchung->ignorieren;
    $hash->{$id}{jaehrlich} += $betrag if $buchung->jaehrlich;
}


1;
