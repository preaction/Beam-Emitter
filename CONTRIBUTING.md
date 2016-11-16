# CONTRIBUTING

This project is free software for the express purpose of collaboration.
We welcome all input, bug reports, feature requests, general comments,
and patches.

If you're not sure about anything, please open an issue and ask, or
e-mail the project founder <preaction@cpan.org> or [talk to us on IRC on
irc.perl.org channel #beam](https://chat.mibbit.com/?channel=%23beam&server=irc.perl.org)!

## Standard of Conduct

To ensure a welcoming, safe, collaborative environment, this project
will enforce a standard of conduct:

* The topic of this project is the project itself. Please stay on-topic.
* Stick to the facts
* Avoid demeaning remarks and sarcasm

Unacceptable behavior will receive a single, public warning. Repeated
unacceptable behavior will result in removal from the project.

Remember, all the people who contribute to this project are volunteers.

## About this Project

### Project Goals

The Beam project is a set of integration patterns to be used in Perl
projects. Integration patterns allow for different systems to work
together with a common set of APIs designed to enable communication and
collaboration between them. Using integration patterns creates more
modular, reusable, maintainable, and isolated code (for those times
where you need to wholly replace a part of your project).

The Beam::Emitter distribution is an event emitter. Event emitters allow
your code to subscribe to interesting events and respond to them,
performing additional actions like logging, data transformation,
notification, and more.

The Beam modules are meant to be easy to use and to follow good OO
design principles while still being Perly.

Inspiration for the Beam project is found in:

* [Enterprise Integration
  Patterns](http://www.enterpriseintegrationpatterns.com)
* [Java's Spring framework](https://spring.io)

Inspiration for this event emitter is also found in JavaScript's event
model and ActionScript 3's event model.

### Repository Layout

This project follows CPAN conventions with some additions, explained
below.

#### `lib/`

Modules are located in the `lib/` directory. Most of the functionality
of the project should be in a module. If the functionality should be
available to users from a script, the script should call the module.

#### `bin/`

Command-line scripts go in the `bin/` directory. Most of the real
functionality of these should be in a library, but these scripts must
call the library function and document the command-line interface.

#### `t/`

All the tests are located in the `t/` directory. See "Getting Started"
below for how to build the project and run its tests.

#### `xt/`

Any extra tests that are not to be bundled with the CPAN module and run
by consumers is located here. These tests are run at release time and
may test things that are expensive or esoteric.

#### `share/`

Any files that are not runnable code but must still be available to the
code are stored in `share/`. This includes default config files, default
content, informational files, read-only databases, and other such. This
project uses [File::Share](http://metacpan.com/pod/File::Share) to
locate these files at run-time.

## What to Contribute

### Comments

The issue tracker is used for both bug reports and to-do list. Anything
on the issue tracker, open or closed, is available for discussion.

### Fixes

For fixes, simply fork and send a pull request. Fixes to anything,
documentation, code, tests, are equally welcome, appreciated, and
addressed!

If you are fixing a bug in the code, please add a regression test to
ensure it stays fixed in the future.

### Features

All contributions are welcome if they fit the scope of this project. If
you're not sure if your feature fits, open an issue and ask. If it doesn't
fit, we will try to find a way to enable you to add your feature in a
related project (if it means changes in this project).

When contributing a feature, please add some basic functionality tests
to ensure the feature is working properly. These tests do not need to be
comprehensive or paranoid, but must at least demonstrate that the
feature is working as documented.

## Getting Started Building and Running Tests

This project uses Dist::Zilla for its releases, but you aren't required
to use it for contributing.

### Using Build.PL

This is the easiest way that requires the fewest dependencies.

Install the project's dependencies and run the tests by doing:

```
perl Build.PL
./Build installdeps
./Build test
```

### Using Makefile.PL

This is the older standard way. If you can install CPAN modules, you can
probably do this. It requires `make` and maybe a C compiler.

Run the tests by doing:

```
perl Makefile.PL
make test
```

Install the module's dependencies by doing:

```
cpanm .
```

### Using Dist::Zilla

Once you have installed Dist::Zilla, you can get this distributions's
dependencies by doing:

```
dzil listdeps --author --missing | cpanm
```

Once all that is done, testing is as easy as:

```
dzil test
```

## Before you Submit Your Contribution

### Copyright and License

All contributions are copyright their respective owners, so make sure you
agree with the project license (found in the LICENSE file) before
contributing.

The list of Contributors is calculated automatically from the Git commit
log. If you do not wish to be listed as a contributor, or if you wish to
be listed as a contributor with a different e-mail address, tell me so
in the ticket or e-mail me at doug@preaction.me.

### Code Formatting and Style

Please try to maintain the existing code formatting and style.

* 4-space indents
* Opening brace on the same line as the opening keyword
    * Exceptions made for lengthy conditionals
* Closing brace on the same column as the opening keyword

### Documentation

Documentation is incredibly important, and contributions will not be
accepted until documentated.

* Methods must be documented inline, above the code of the method
* Method documentation must include name, sample usage, and description
  of inputs and outputs
* Attributes must be documented inline, above the attribute declaration
* Attribute documentation must include name, sample value, and
  description
* User-executable scripts must be documented with a short synopsis,
  a longer description, and all the arguments and options explained

### New Prerequisites

Though this project has a `cpanfile`, a `Makefile.PL`, and maybe even
a `Build.PL`, these files are auto-generated and should not be edited.
To add new prereqs, you must add them to the `dist.ini` file in the
following sections:

* `[Prereqs]` - Runtime requirements
* `[Prereqs / TestRequires]` - Test-only requirements
* `[Prereqs / Recommends]` - Runtime recommendations, for optional
  modules
* `[Prereqs / TestRecomments]` - Test-only recommendations, for optional
  modules

If the section doesn't already exist, you can add it to the bottom of
the `dist.ini` file.

The `Recommends` and `TestRecommends` will be automatically installed by
Travis CI to test those parts of the code.

OS-specific prerequisites can be added using the
[Dist::Zilla::Plugin::OSPrereqs](http://metacpan.org/pod/Dist::Zilla::Plugin::OSPrereqs)
module.

