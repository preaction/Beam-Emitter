
use strict;
use warnings;
use Test::More;
use Test::Fatal;

{
    package My::Emitter;
    use Moo;
    with 'Beam::Emitter';
}

my @methods = qw(
    HashRef
    weaken refaddr
    croak
);

for my $method ( @methods ) {
    like exception { My::Emitter->new->$method },
        qr/Can't locate object method "$method" via package "My::Emitter"/,
        $method . ' cleaned up and not available on our composed class';
}

done_testing;
