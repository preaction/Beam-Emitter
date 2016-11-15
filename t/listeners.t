#! perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

use Scalar::Util qw[ refaddr ];

{
    package Foo;
    use Moo;
    with 'Beam::Emitter';
}

{
    package Goo;
    use Moo;
    extends 'Beam::Listener';

    has attr => ( is => 'ro', required => 1 );

}

sub byref { refaddr $a <= refaddr $b }

my $foo = Foo->new;

my $s11 = sub { 'evt11' };
my $s12 = sub { 'evt12' };
my $s21 = sub { 'evt21' };
my $s22 = sub { 'evt22' };

my $us11 = $foo->subscribe( evt1 => $s11 );
my $us12 = $foo->subscribe( evt1 => $s12 );
my $us21 = $foo->subscribe( evt2 => $s21 );

# try an alternate listener class.

# test constructor is being called with args
throws_ok(
    sub { $foo->subscribe( evt2 => $s22, class => 'Goo' ) },
    qr/missing required arguments/i,
    "missing attr for custom listener class"
);

my $us22 = $foo->subscribe( evt2 => $s22, class => 'Goo', attr => 's22' );

{
    my @s = sort byref $s11, $s12;
    my @cb = sort byref map { $_->callback } $foo->listeners( 'evt1' );
    is_deeply( \@cb, \@s, 'initial evt1 listeners' );
}

{
    my @s = sort byref $s21, $s22;
    my @cb = sort byref map { $_->callback } $foo->listeners( 'evt2' );
    is_deeply( \@cb, \@s, 'initial evt2 listeners' );
}

{
    &$us12;
    my @l  = sort byref $foo->listeners( 'evt1' );
    my @cb = map { $_->callback } @l;
    is_deeply( \@cb,  [ $s11 ], 'after evt1 listener removal' );
    ok( $l[0]->isa( 'Beam::Listener' ) && ! $l[0]->isa( 'Goo' ), 'default Listener class' );
}

{
    &$us21;
    my @l  = sort byref $foo->listeners( 'evt2' );
    my @cb = map { $_->callback } @l;
    is_deeply( \@cb,  [ $s22 ], 'after evt2 listener removal' );
    ok( $l[0]->isa( 'Goo' ), 'custom Listener class' );
}


done_testing;
