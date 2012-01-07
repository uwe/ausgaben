#!/usr/bin/perl

use strict;
use warnings;

use rlib;

use Test::Most die => tests => 9;


use_ok('Ausgaben::Schema');
use_ok('Ausgaben::API');


my $api = _init_api('dbi:mysql:ausgaben_test', 'root', 'root');

# Personen anlegen
$api->person_neu(name => 'Uwe');
$api->person_neu(name => 'Peggy');
my %P = _name2id($api, 'Person');

is(scalar keys %P, 2, 'Anzahl Personen');

# Verteilungen anlegen
$api->verteilung_neu(name => 'U',  person => {$P{Uwe}   => 1});
$api->verteilung_neu(name => 'P',  person => {$P{Peggy} => 1});
$api->verteilung_neu(name => 'PU', person => {$P{Peggy} => 1, $P{Uwe} => 1});
my %V = _name2id($api, 'Verteilung');

is(scalar keys %V, 3, 'Anzahl Verteilungen');

# Konten anlegen
$api->konto_neu(name => 'U',  verteilung => $V{U});
$api->konto_neu(name => 'P',  verteilung => $V{P});
$api->konto_neu(name => 'PU', verteilung => $V{PU});
my %K = _name2id($api, 'Konto');

is(scalar keys %K, 3, 'Anzahl Konten');

# Haendler anlegen
$api->haendler_neu(name => 'H1');
$api->haendler_neu(name => 'H2');
my %H = _name2id($api, 'Haendler');

is(scalar keys %H, 2, 'Anzahl Haendler');

# Kategorien anlegen
$api->kategorie_neu(name => 'K1');
$api->kategorie_neu(name => 'K2');
my %KAT = _name2id($api, 'Kategorie');

is(scalar keys %KAT, 2, 'Anzahl Kategorien');



my %AB = map { $_ => 0 } values %K;

eq_or_diff($api->konto_anfangsbestand(datum => '2010-12'), \%AB, 'leerer Anfangsbestand');


$api->buchung_neu(datum      => '2010-01-01',
                  verteilung => $V{PU},
                  konto      => {$K{U} => -20},
                 );
$AB{$K{U}} = '-20';

eq_or_diff($api->konto_anfangsbestand(datum => '2010-12'), \%AB, 'Anfangsbestand nach Buchung');



sub _init_api {
    my @connect = @_;

    my $schema = Ausgaben::Schema->connect(@connect);

    # Buchungsdaten loeschen
    $schema->storage->dbh_do(
        sub {
            my ($storage, $dbh) = @_;
            $dbh->do('TRUNCATE '.$_) foreach (qw(betrag
                                                 buchung
                                                 haendler
                                                 kategorie
                                                 konto
                                                 monat_konto
                                                 monat_person
                                                 person
                                                 verteilung
                                                 verteilung_person
                                               ));
        },
    );

    return Ausgaben::API->new(schema => $schema);
}

sub _name2id {
    my ($api, $class) = @_;

    return map { $_->name => $_->id } $api->rs($class)->all;
}
