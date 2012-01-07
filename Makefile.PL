
use inc::Module::Install;
use Module::Install::Catalyst;

name 'Ausgaben';
all_from 'lib\Ausgaben.pm';

requires 'Catalyst::Runtime' => '5.80025';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Template';
requires 'DBIx::Class';
requires 'DBIx::Class::Candy';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General';

test_requires 'Test::More' => '0.88';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
