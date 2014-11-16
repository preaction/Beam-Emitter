package Beam::Emitter;

use strict;
use warnings;

use Moo::Role;
use Types::Standard qw(:all);
use Scalar::Util qw( refaddr );
use Carp qw( croak );
use Beam::Event;

has _listeners => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

sub subscribe {
    my ( $self, $name, $sub ) = @_;
    push @{ $self->_listeners->{$name} }, $sub;
    return;
}

*on = \&subscribe;

sub unsubscribe {
    my ( $self, $name, $sub ) = @_;
    if ( !$sub ) {
        delete $self->_listeners->{$name};
    }
    else {
        my $listeners = $self->_listeners->{$name};
        my $idx = 0;
        $idx++ until $idx > $#{$listeners} or refaddr $listeners->[$idx] eq refaddr $sub;
        if ( $idx > $#{$listeners} ) {
            croak "Could not find sub in listeners";
        }
        splice @{$self->_listeners->{$name}}, $idx, 1;
    }
    return;
}

*un = \&unsubscribe;

sub emit {
    my ( $self, $name, %args ) = @_;
    my $class = delete $args{ class } || "Beam::Event";
    $args{ emitter  } = $self;
    $args{ name     } = $name;
    my $event = $class->new( %args );
    for my $listener ( @{ $self->_listeners->{$name} } ) {
        $listener->( $event );
        last if $event->is_stopped;
    }
    return $event;
}

sub emit_args {
    my ( $self, $name, @args ) = @_;
    for my $listener( @{ $self->_listeners->{$name} } ) {
        $listener->( @args );
    }
    return;
}

1;
__END__

=head1 NAME

Beam::Emitter - Role for event emitting classes

=head1 SYNOPSIS

    package My::Emitter;

    use Moo;
    with 'Beam::Emitter';

    sub do_something {
        my ( $self ) = @_;

        # Give event listeners a chance to prevent something
        my $event = $self->emit( "before_something" );
        return if $event->is_default_stopped;

        # ... do something

        # Notify listeners we're done with something
        $self->emit( 'after_something' );
    }

=head1 DESCRIPTION

This role is used by classes that want to emit events to subscribers.

=head1 METHODS

=head2 subscribe ( event_name, subref )

=head2 on ( event_name, subref )

Subscribe to an event from this object. C<event_name> is the name of the event.
C<subref> is a subroutine reference that takes a single argument, the
C<Beam::Event> that is being emitted.

=head2 un ( event_name [, subref ] )

=head2 unsubscribe ( event_name [, subref ] )

Unsubscribe from an event. C<event_name> is the name of the event. C<subref> is
the single listener subref to be removed. If no subref is given, will remove
all listeners for this event.

=head2 emit ( name, event_args )

Emit a L<Beam::Event> with the given C<name>. C<event_args> is a list of name => value
pairs to give to the C<Beam::Event> object.

Use the C<class> key in event_args to specify a different Event class.

=head2 emit_args ( name, callback_args )

Emit an event with the given C<name>. C<callback_args> is a list that will be given
directly to each subscribed callback.

Use this to completely avoid using L<Beam::Event> completely.
