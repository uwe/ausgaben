package Ausgaben::Web;

###TODO### Monat als Parameter (oder in URL)
###TODO### MonatKategorie statt kategorie_id nur id? Besser fuer process_report()

use strict;
use warnings;

use Carp qw(croak);
use DateTime;
use Template;

use Ausgaben::API;
use Ausgaben::Schema;


my $schema = Ausgaben::Schema->connect('dbi:mysql:ausgaben', 'root', 'root');
my $api    = Ausgaben::API->new(schema => $schema);
my $tt2    = Template->new({INCLUDE_PATH => 'tmpl'});


sub handle {
    my ($class, $req) = @_;

    my ($data, $template);
    if ($req->path =~ m|^/report|) {
        my $name  = 'Kategorie';
        $name     = 'Haendler' if $req->path =~ m|^/report/haendler|;
        $data     = $class->process_report($req, $name);
        $template = 'report.html';
    } else {
        $data     = $class->process($req);
        $template = 'index.html';
    }

    my $body = '';
    $tt2->process($template, $data, \$body) or die $tt2->error;

    my $res = $req->new_response(200);
    $res->content_type('text/html');
    $res->body($body);

    return $res;
}

sub process_report {
    my ($class, $req, $name) = @_;

    my $id = lc($name) . '_id';

    my %monat = ();

    # lade alle Monatsausgaben
    foreach my $monat ($api->rs('Monat'.$name)->all) {
        my $ymd = $monat->datum->ymd;
        $monat{$ymd}{datum} ||= $monat->datum;

        my $ausgaben = $monat->gesamt - $monat->ignoriert
            - int($monat->jaehrlich / 12);
        $monat{$ymd}{gesamt}     += $ausgaben;
        $monat{$ymd}{$monat->$id} = $ausgaben;
    }

    # entferne unbenutzte Monate
    my @monat = grep { $_->{gesamt} } values %monat;

    # sortiere Monate
    @monat = sort { $a->{datum} <=> $b->{datum} } @monat;

    my $kat_rs = $api->rs($name)->search({}, {order_by => 'name'});

    return {item   => $name,
            NAMES  => [$kat_rs->all],
            MONATE => \@monat,
           };
}

sub process {
    my ($class, $req) = @_;

    my $today = DateTime->today;

    # Anzeigemonat wechseln?
    if (($req->param('monat') || '') =~ /^(\d\d\d\d)-(\d\d)$/) {
        $today = DateTime->new(year => $1, month => $2, day => 1);
    }

    # lade alle Konten
    my @konto = $api->rs('Konto')->search({}, {order_by => 'reihenfolge'})->all;

    # hole Formulardaten
    my %param = map { $_ => $req->param($_) || '' }
        qw(id datum haendler_id kategorie_id verteilung_id ignorieren bemerkung);
    my %konto = ();
    foreach my $konto (@konto) {
        my $name   = 'konto_' . $konto->id;
        $param{$name} = $req->param($name);
        my $betrag = _money2db($param{$name});
        $konto{$konto->id} = $betrag if $betrag;
    }
    if ($param{haendler_id} eq '-1') {
        $param{haendler_name} = $req->param('haendler_name') || '';
    }
    if ($param{kategorie_id} eq '-1') {
        $param{kategorie_name} = $req->param('kategorie_name') || '';
    }

    # Haendler anlegen?
    if ($param{haendler_name}) {
        my $haendler = $api->haendler_neu(name => $param{haendler_name});
        $param{haendler_id} = $haendler->id;
        delete $param{haendler_name};
    }
    # Kategorie anlegen?
    if ($param{kategorie_name}) {
        my $kategorie = $api->kategorie_neu(name => $param{kategorie_name});
        $param{kategorie_id} = $kategorie->id;
        delete $param{kategorie_name};
    }


    # Reihenfolge aendern?
    if (my $id = $req->param('up')) {
        my $buchung = $api->rs('Buchung')->find($id);
        $buchung->move_previous;
    }
    if (my $id = $req->param('down')) {
        my $buchung = $api->rs('Buchung')->find($id);
        $buchung->move_next;
    }


    # neue Buchung?
    my $form_data = 0;
    foreach (values %param) {
        next unless $_;
        $form_data = 1;
        last;
    }
    $form_data = 0 if $param{haendler_id}  eq '-1';
    $form_data = 0 if $param{kategorie_id} eq '-1';

    my %error = ();
    if ($form_data) {
        # Pflichtparameter
        foreach (qw(datum verteilung_id)) {
            $error{$_} = 1 unless $param{$_};
        }

        # mindestens ein Betrag?
        $error{konto} = 1 unless keys %konto;

        # Datum parsen
        my $datum = _parse_date($param{datum});
        if ($datum) {
            $param{datum} = $datum->dmy('.');
        } else {
            $error{datum} = 1;
        }

        unless (%error) {
            my %b = (datum      => _date2db($param{datum}),
                     haendler   => $param{haendler_id},
                     kategorie  => $param{kategorie_id},
                     verteilung => $param{verteilung_id},
                     ignorieren => $param{ignorieren},
                     jaehrlich  => '',
                     bemerkung  => $param{bemerkung},
                     konto      => \%konto,
                    );

            my $buchung = do {
                if ($param{id}) {
                    $api->buchung_edit(%b, id => $param{id});
                } else {
                    $api->buchung_neu(%b);
                }
            };

            $today = $buchung->datum;

            # Paramter loeschen
            %param = ();
        }
    }


    # Buchung aendern?
    my $edit_id = $req->param('edit') || '';
    if ($edit_id) {
        my $buchung = $api->rs('Buchung')->find($edit_id);
        %param = (id            => $buchung->id,
                  datum         => $buchung->datum->dmy('.'),
                  haendler_id   => $buchung->haendler_id,
                  kategorie_id  => $buchung->kategorie_id,
                  verteilung_id => $buchung->verteilung_id,
                  ignorieren    => $buchung->ignorieren,
                  bemerkung     => $buchung->bemerkung,
                 );
        foreach my $betrag ($buchung->betraege) {
            $param{'konto_' . $betrag->konto_id} = _db2money($betrag->betrag);
        }
        $today = $buchung->datum;
    }


    # Buchungen laden
    my $start      = $today->set(day => 1);
    my $ende       = $today->clone->add(months => 1)->subtract(days => 1);
    my $buchung_rs = $api->rs('Buchung')
        ->search({datum    => {-between => [$start->ymd, $ende->ymd]}},
                 {order_by => 'datum, reihenfolge'},
                );

    my $kontostand = $api->konto_anfangsbestand(
	datum => DateTime->today->set_day(1)->add(months => 1),
    );

    my $monat_ausgaben = $api->monat_ausgaben_range(
	von  => DateTime->today->subtract(years => 1),
	bis  => DateTime->today,
	skip => 1,
    );

    return {
	KONTO      => \@konto,
	VERTEILUNG => [$api->rs('Verteilung')->all],
	KATEGORIE  => [$api->rs('Kategorie' )->search(undef, {order_by => 'name'})->all],
	HAENDLER   => [$api->rs('Haendler'  )->search(undef, {order_by => 'name'})->all],
	PERSON     => [$api->rs('Person'    )->all],
	BUCHUNG    => [$buchung_rs->all],
	KONTOSTAND => $kontostand,
	MONAT      => $monat_ausgaben,
	DATA       => \%param,
	ERROR      => \%error,
	edit_id    => $req->param('edit') || '',
    };
}

sub _parse_date {
    my ($input) = @_;

    # tt.mm.jjjj
    if ($input =~ /^(\d{1,2})\.(\d{1,2})\.(\d{4})$/) {
        return DateTime->new(day   => $1,
                             month => $2,
                             year  => $3,
                            );
    }

    my $today = DateTime->today;

    # tt_mm_jj
    if ($input =~ /^(\d{1,2})\D(\d{1,2})\D(\d{2,4})$/) {
        my $day   = $1;
        my $month = $2;
        my $year  = $3;

        # 0 .. +10 -> 20xx
        if ($year <= $today->year - 1990) {
            $year += 2000;
        } elsif ($year <= $today->year - 1900) {
            $year += 1900;
        }
        return DateTime->new(day   => $day,
                             month => $month,
                             year  => $year,
                            );
    }

    # tt_mm
    if ($input =~ /^(\d{1,2})\D(\d{1,2})\D?$/) {
        my $date = DateTime->new(day   => $1,
                                 month => $2,
                                 year  => $today->year,
                                );
        # 31.12. Anfang Januar?
        $date->subtract(years => 1) if $date > $today;

        return $date;
    }

    # 0, -
    if ($input eq '0' or $input eq '-') {
        return $today;
    }

    # tt
    if ($input =~ /^(\d{1,2})$/) {
        if ($1 > $today->day) {
            return $today->subtract(months => 1)->set_day($1);
        }
        return $today->set_day($1);
    }

    # -x
    if ($input =~ /^-(\d)$/) {
        return $today->subtract(days => $1);
    }

    return;
}

sub _date2db {
    my ($input) = @_;

    if ($input =~ /^(\d{1,2})\.(\d{1,2})\.(\d{4})$/) {
        return "$3-$2-$1";
    }

    croak "Unknown date format: $input";
}

sub _money2db {
    my ($input) = @_;
    return unless $input;

    if ($input =~ /^([+-]?)(\d*)[,.]?(\d*?)$/) {
        my $sign   = $1 || '';
        my $number = ($2 || 0) * 100;
        if ($3) {
            if (length $3 == 1) {
                # e. g. 0.5 -> 50 cent
                $number += $3.'0';
            } else {
                $number += $3;
            }
        }
        $number = - $number if $sign eq '-';
        return $number;
    }

    warn "Unmatched _money2db regex: $input";

    return;
}

sub _db2money {
    my ($output) = @_;

    if ($output =~ /^([+-]?)(\d*?)(\d{1,2})$/) {
        return sprintf("%s%d,%02d", $1 || '', $2 || 0, $3);
    }

    warn "Unmatched _db2money regex: $output";

    return;
}


1;
