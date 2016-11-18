
=head1 DESCRIPTION

This test ensures that the API of the Beam::Emitter role is kept to
a minimum, and any imported subs are cleaned up before the role is
composed into a class. Any new methods must be added here, but only
after it's certain there's no way to add the functionality without
a new method.

=cut

use strict;
use warnings;
use Test::More;
use Test::API;

{
    package My::Emitter;
    use Moo;
    with 'Beam::Emitter';
}

class_api_ok(
    'My::Emitter',
    qw[
      DOES
      after
      around
      before
      emit
      emit_args
      extends
      has
      listeners
      new
      on
      subscribe
      un
      unsubscribe
      with
      ]
);

done_testing;
