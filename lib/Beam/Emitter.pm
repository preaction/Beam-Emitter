package Beam::Emitter;
# ABSTRACT: Role for event emitting classes

use strict;
use warnings;

use Moo::Role;
use Types::Standard qw(:all);
use Scalar::Util qw( refaddr );
use Carp qw( croak );
use Beam::Event;

# The event listeners on this object, a hashref of arrayrefs of
# EVENT_NAME => [ CALLBACK, ... ]
has _listeners => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

=method subscribe ( event_name, subref )

Subscribe to an event from this object. C<event_name> is the name of the event.
C<subref> is a subroutine reference that will get either a L<Beam::Event> object
(if using the L<emit> method) or something else (if using the L<emit_args> method).

Return a coderef that, when called, unsubscribe the current subref.

    my $unsubscribe = $emitter->subscribe( open_door => sub {
        warn "ding!";
    } );

    $emitter->emit( 'open_door' );  # ding!

    $unsubscribe->();

    $emitter->emit( 'open_door' );  # no ding


=cut

sub subscribe {
    my ( $self, $name, $sub ) = @_;
    push @{ $self->_listeners->{$name} }, $sub;
    return sub { 
        $self->unsubscribe($name => $sub);
    };
}

=method on ( event_name, subref )

Alias for L</subscribe>.

=cut

*on = \&subscribe;

=method unsubscribe ( event_name [, subref ] )

Unsubscribe from an event. C<event_name> is the name of the event. C<subref> is
the single listener subref to be removed. If no subref is given, will remove
all listeners for this event.

=cut

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

=method un ( event_name [, subref ] )

An alias for L</unsubscribe>

=cut

*un = \&unsubscribe;

=method emit ( name, event_args )

Emit a L<Beam::Event> with the given C<name>. C<event_args> is a list of name => value
pairs to give to the C<Beam::Event> constructor.

Use the C<class> key in C<event_args> to specify a different Event class.

=cut

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

=method emit_args ( name, callback_args )

Emit an event with the given C<name>. C<callback_args> is a list that will be given
directly to each subscribed callback.

Use this if you want to avoid using L<Beam::Event>, though you miss out on the control
features like L<stop|Beam::Event/stop> and L<stop default|Beam::Event/stop_default>.

=cut

sub emit_args {
    my ( $self, $name, @args ) = @_;
    for my $listener( @{ $self->_listeners->{$name} } ) {
        $listener->( @args );
    }
    return;
}

1;
__END__

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

    sub custom_something {
        my ( $self ) = @_;

        # Send arbitrary arguments to our event listener
        $self->emit_args( 'custom_something', "foo", "bar" );
    }

=head1 DESCRIPTION

This role is used by classes that want to emit events to subscribers. A
subscriber registers interest in an event using the L<subscribe> or L<on>
methods. Then, the class can L<emit> events to be handled by any listening
subscribers.

Using the L<Beam::Event> class, subscribers can stop an event from being
processed, or prevent the default action from happening.

=head2 Using Beam::Event

L<Beam::Event> is an event object with some simple methods to allow subscribers
to influence the handling of the event. By calling L<the stop
method|Beam::Event/stop>, subscribers can stop all futher handling of the
event. By calling the L<the stop_default method|Beam::Event/stop_default>,
subscribers can allow other subscribers to be notified about the event, but let
the emitter know that it shouldn't continue with what it was going to do.

For example, let's build a door that notifies when someone tries to open it.
Different instances of a door should allow different checks before the door
opens, so we'll emit an event before we decide to open.

    package Door;
    use Moo;
    with 'Beam::Emitter';

    sub open {
        my ( $self, $who ) = @_;
        my $event = $self->emit( 'before_open' );
        return if $event->is_default_stopped;
        $self->open_the_door;
    }

    package main;
    my $door = Door->new;
    $door->open;

Currently, our door will open for anybody. But let's build a door that only
open opens after noon (to keep us from having to wake up in the morning).

    use Time::Piece;
    my $restful_door = Door->new;

    $restful_door->on( before_open => sub {
        my ( $event ) = @_;

        my $time = Time::Piece->now;
        if ( $time->hour < 12 ) {
            $event->stop_default;
        }

    } );

    $restful_door->open;

By calling L<stop_default|Beam::Event/stop_default>, we set the
L<is_default_stopped|Beam::Event/is_default_stopped> flag, which the door sees
and decides not to open.

=head2 Using Custom Events

The default C<Beam::Event> is really only useful for notifications. If you want
to give your subscribers some data, you need to create a custom event class.
This allows you to add attributes and methods to your events (with all
the type constraints and coersions you want).

Let's build a door that can keep certain people out. Right now, our door
doesn't care who is trying to open it, and our subscribers do not get enough
information to deny entry to certain people.

So first we need to build an event object that can let our subscribers know
who is knocking on the door.

    package Door::Knock;
    use Moo;
    extends 'Beam::Event';

    has who => (
        is => 'ro',
        required => 1,
    );

Now that we can represent who is knocking, let's notify our subscribers.

    package Door;
    use Moo;
    use Door::Knock; # Our emitter must load the class, Beam::Emitter will not
    with 'Beam::Emitter';

    sub open {
        my ( $self, $who ) = @_;
        my $event = $self->emit( 'before_open', class => 'Door::Knock', who => $who );
        return if $event->is_default_stopped;
        $self->open_the_door;
    }

Finally, let's build a listener that knows who is allowed in the door.

    my $private_door = Door->new;
    $private_door->on( before_open => sub {
        my ( $event ) = @_;

        if ( $event->who ne 'preaction' ) {
            $event->stop_default;
        }

    } );

    $private_door->open;

=head2 Without Beam::Event

Although checking C<is_default_stopped> is completely optional, if you do not
wish to use the C<Beam::Event> object, you can instead call L<emit_args>
instead of L<emit> to give arbitrary arguments to your listeners.

    package Door;
    use Moo;
    with 'Beam::Emitter';

    sub open {
        my ( $self, $who ) = @_;
        $self->emit_args( 'open', $who );
        $self->open_the_door;
    }

There's no way to stop the door being opened, but you can at least notify
someone before it does.

=head1 SEE ALSO

=over 4

=item L<Beam::Event>

=item L<http://perladvent.org/2013/2013-12-16.html>

Coordinating Christmas Dinner with Beam::Emitter by Yanick Champoux.

=back

