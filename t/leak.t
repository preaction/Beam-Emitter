
use strict;
use warnings;
use Test::More;
use Beam::Emitter;
BEGIN {
    eval { require Test::LeakTrace; Test::LeakTrace->import( 'no_leaks_ok' ) };
    if ( $@ ) {
        plan skip_all => 'Test::LeakTrace required for this test';
        exit;
    }
}

{
    package My::Emitter;
    use Moo;
    with 'Beam::Emitter';
}


no_leaks_ok {
    my $b = My::Emitter->new;
    my $cb; $b->on( derp => $cb = sub { $_[0]->emitter->un( derp => $cb ); undef $cb } );
    $b->emit( 'derp' );
};

no_leaks_ok {
    my $b = My::Emitter->new;
    my $cb; $cb = $b->on( derp => sub { $cb->() } );
    $b->emit( 'derp' );
};

no_leaks_ok {
    my $b = My::Emitter->new;
    my $cb; $cb = $b->on( derp => sub { $cb->() } );
};

no_leaks_ok {
    my $b = My::Emitter->new;
    my $cb; $cb = $b->on( derp => sub { } );
    $b->emit( 'derp' );
    $cb->();
};

done_testing;
