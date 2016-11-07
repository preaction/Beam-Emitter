use strict;
use warnings;

use Test::Exception tests => 1;

use Beam::Emitter;

{
    package MyEmitter;

    use Moo; with 'Beam::Emitter';
}

my $emitter = MyEmitter->new;

my $unsubscribe = $emitter->on( ping => sub { } );

# simulate Global Destruction with $emitter destroyed first

undef $emitter;

lives_ok { $unsubscribe->() } 'unsubscribe survived destroyed emitter';






