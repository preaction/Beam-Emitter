
use strict;
use warnings;
use Test::More;

subtest 'Allow a single listener to catch all events' => sub {

    {
        package My::Emitter::CatchAll;
        use Moo;
        with 'Beam::Emitter';
        after emit => sub {
            my ( $self, $event_name, @args ) = @_;
            return if $event_name eq '*'; # prevent recursion
            $self->emit( '*', name => $event_name, @args );
        };
    }

    my $emitter = My::Emitter::CatchAll->new;
    my @all;
    my %events = (
        foo => [],
        bar => [],
    );

    $emitter->on( '*', sub { push @all, \@_ } );
    $emitter->on( 'foo', sub { push @{ $events{foo} }, \@_ } );
    $emitter->on( 'bar', sub { push @{ $events{bar} }, \@_ } );

    $emitter->emit( 'foo' );
    is scalar @{ $events{ foo } }, 1, 'foo event caught by foo listener';
    is scalar @{ $events{ bar } }, 0, 'foo event not caught by bar listener';
    is scalar @all, 1, 'foo event caught by catch-all';
    is $all[0][0]->name, $events{ foo }[0][0]->name,
        'catch-all listener event has same name as original listener event';

    $emitter->emit( 'bar' );
    is scalar @{ $events{ foo } }, 1, 'bar event not caught by foo listener';
    is scalar @{ $events{ bar } }, 1, 'bar event caught by bar listener';
    is scalar @all, 2, 'bar event caught by catch-all';
    is $all[1][0]->name, $events{ bar }[0][0]->name,
        'catch-all listener event has same name as original listener event';

};

done_testing;
