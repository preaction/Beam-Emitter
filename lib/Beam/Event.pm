package Beam::Event;
our $VERSION = '1.006';
# ABSTRACT: Base Event class

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

=head1 SEE ALSO

=over 4

=item L<Beam::Emitter>

=back

=cut

use strict;
use warnings;

use Moo;
use Types::Standard qw(:all);

=attr name

The name of the event. This is the string that is given to L<Beam::Emitter/on>.

=cut

has name => (
    is          => 'ro',
    isa         => Str,
    required    => 1,
);

=attr emitter

The emitter of this event. This is the object that created the event.

=cut

has emitter => (
    is          => 'ro',
    isa         => ConsumerOf['Beam::Emitter'],
    required    => 1,
);

=attr is_default_stopped

This is true if anyone called L</stop_default> on this event.

Your L<emitter|Beam::Emitter> should check this attribute before trying to do
what the event was notifying about.

=cut

has is_default_stopped => (
    is          => 'rw',
    isa         => Bool,
    default     => sub { 0 },
);

=attr is_stopped

This is true if anyone called L</stop> on this event.

When using L<the emit method|Beam::Emitter/emit>, this is checked automatically
after every callback, and event processing is stopped if this is true.

=cut

has is_stopped => (
    is          => 'rw',
    isa         => Bool,
    default     => sub { 0 },
);

=method stop_default ()

Calling this will cause the default behavior of this event to be stopped.

B<NOTE:> Your event-emitting object must check L</is_default_stopped> for this
behavior to work.

=cut

sub stop_default {
    my ( $self ) = @_;
    $self->is_default_stopped( 1 );
}

=method stop ()

Calling this will immediately stop any further processing of this event.
Also calls L</stop_default>.

=cut

sub stop {
    my ( $self ) = @_;
    $self->stop_default;
    $self->is_stopped( 1 );
}

1;
__END__

