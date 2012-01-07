package Ausgaben;

use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use Catalyst qw/ConfigLoader Static::Simple/;

extends 'Catalyst';


__PACKAGE__->config(
    name => 'Ausgaben',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

__PACKAGE__->setup();


1;
