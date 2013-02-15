package Beam::Event;

use strict;
use warnings;

use Moo;
use MooX::Types::MooseLike::Base qw(:all);

has name => (
    is          => 'ro',
    isa         => Str,
    required    => 1,
);

has emitter => (
    is          => 'ro',
    isa         => ConsumerOf['Beam::Emitter'],
    required    => 1,
);

has is_default_stopped => (
    is          => 'rw',
    isa         => Bool,
    default     => sub { 0 },
);

has is_stopped => (
    is          => 'rw',
    isa         => Bool,
    default     => sub { 0 },
);

sub stop_default {
    my ( $self ) = @_;
    $self->is_default_stopped( 1 );
}

sub stop {
    my ( $self ) = @_;
    $self->stop_default;
    $self->is_stopped( 1 );
}

1;
__END__

=head1 NAME

Beam::Event - Base Event class

=head1 SYNOPSIS

    # My::Emitter consumes the Beam::Emitter role
    my $emitter = My::Emitter->new;
    $emitter->on( "foo", sub {
        my ( $event ) = @_;
        print "Foo happened!\n";
        # stop this event from continuing
        $event->stop;
    } );
    my $event = $emitter->emit( "foo" );

=head1 DESCRIPTION

This is the base event class for C<Beam::Emitter> objects.

The base class is only really useful for notifications. Create a subclass
to add data attributes.

=head1 ATTRIBUTES

=head2 name

The name of the event. This is the string that is given to C<Beam::Emitter::on>.

=head2 emitter

The emitter of this event. This is the object that created the event.

=head1 METHODS

=head2 stop ()

Calling this will immediately stop any further processing of this event.
Also calls C<stop_default()>.

=head2 stop_default ()

Calling this will cause the default behavior of this event to be stopped.

