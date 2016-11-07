use strict;
use warnings;

use Test::More tests => 2;

{
    package My::Emitter;

    use Moo;
    with 'Beam::Emitter';

    has '+beam_event_prefix' => (
        default => 'My::Event',
    );
}

{
    package My::Event::Foo;

    use Moo;
    extends 'Beam::Event';

}

{
    package Their::Event::Foo;

    use Moo;
    extends 'Beam::Event';

}

my $emitter = My::Emitter->new;

my %seen;

for my $event ( qw/ Foo Their::Event::Foo / ) {
    $emitter->on( $event => sub {
            $seen{$event} = ref shift;
    });
}

$emitter->emit_class( 'Foo' );

is $seen{Foo} => 'My::Event::Foo', 'emit_class("Foo")';

$emitter->emit_class( '+Their::Event::Foo' );

is $seen{'Their::Event::Foo'} => 'Their::Event::Foo', 'emit_class("+Their::Event::Foo")';
