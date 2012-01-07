#!/usr/bin/perl

use strict;
use warnings;

use Plack::Builder;
use Plack::Request;

use lib 'lib';
use Ausgaben::Web;


my $app = sub {
    my $req = Plack::Request->new(shift);
    my $res = Ausgaben::Web->handle($req);

    return $res->finalize;
};


builder {
    $app;
};
