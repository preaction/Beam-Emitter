use strict;
use warnings;

use Test::More tests => 2;

{
    package MyEmitter;
    use Moose; with 'Beam::Emitter';
}

my $emitter = MyEmitter->new;

$emitter->on( 'foo', sub { pass "foo" } );
$emitter->on( '*',   sub { pass "*" } );

$emitter->emit( 'foo' );




