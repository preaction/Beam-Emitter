
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
