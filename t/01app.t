#!C:\strawberry\perl\bin\perl.exe
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Ausgaben' }

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
