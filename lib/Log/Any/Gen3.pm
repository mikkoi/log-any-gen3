use 5.008001;
use strict;
use warnings;

package Log::Any::Gen3;

# ABSTRACT: Bringing loggers and listeners together
our $VERSION = '3.001';

sub get_logger {
    my ($class, %args) = @_;
    my $proxy_class = delete $args{proxy_class} || 'Log::Any::Gen3::Proxy::Basic';
    if (!$args{category}) {
        $args{category} = caller;
    }
    (my $file = "$proxy_class.pm") =~ s{::}{/}g;
    require $file;
    return $proxy_class->new(%args);
}

=pod

=encoding utf8

=head1 SYNOPSIS

In a CPAN or other module:

    package Foo;
    use Log::Any::Gen3 qw($log);

    # log a string
    $log->error("an error occurred");

    # log a string and some data
    $log->info("program started",
        {progname => $0, pid => $$, perl_version => $]});

    # log a string and data using a format string
    $log->debugf("arguments are: %s", \@_);

    # log an error and throw an exception
    die $log->fatal("a fatal error occurred");

    # use context
    # Add or replace a full context
    $log->context( { request_id => 'REQ9876', userid => 1234, transaction => 0 } );
    # Add or replace one item in the context.
    $log->context( transaction => 0 );
    $log->info( "User access verified" )
    {
        $log->context( transaction => 1 );
        # Only log the context
        $log->info();
        $log->debug( "Saving user order" );
    }
    # context is again: transaction => 0
    $log->info( "Saved user order. Send confirmation email" );

In a Moo/Moose-based module:

    package Foo;
    use Moo;
    use Log::Any ();

    has log => (
        is => 'ro',
        default => sub { Log::Any->get_logger },
    );
    sub do_the_thing {
        my ($self) = @_;
        $self->_log->info('Doing the thing');
        return;
    }

In your application:

    use Foo;
    use Log::Any::Adapter;

    # Send all logs to Log::Log4perl
    Log::Any::Adapter->set('Log4perl');

    # Send all logs to Log::Dispatch
    my $log = Log::Dispatch->new(outputs => [[ ... ]]);
    Log::Any::Adapter->set( 'Dispatch', dispatcher => $log );

    # See Log::Any::Adapter documentation for more options

=head1 MOTIVATION

B<Log::Any::Gen3> aims to be an iterative improvement
to L<Log::Any>. It focuses especially in improving the areas
of flexibility and robustness/reliability:

B<Log::Any::Gen3> adds a "sub framework" which allows
configuration changes in runtime, triggered by, for example,
changes in configuration files. Adapters can change their
approved categories in runtime, thus improving debugging
possibilities. Querying the active configuration is possible.

B<Log::Any::Gen3> also allows the adapters to communicate with
the proxies via hooks. This makes it possible to extract
information such as file name and position only when
the adapter requests it.

B<Log::Any::Gen3> wants to be typesafe, at least as typesafe
as is possible in Perl. It defines a tighter interface
for the proxy with the intent of preventing the logging
system from crashing due to programmer error.
Logging system crashing must not be allowed under any cimcumstances!

In the interest of extreme speed, logging framework B<Log::Any::Gen3>
also allows an "inflexibel" setup where proxy and adapter
are coupled already at the start of the program and flexible
configuration is not possible. This can also reduce the program
size if unnecessary code is left out.

=head1 BACKGROUND

Perl community - just like Java, Python, C/C++ and other
constantly evolving programming language communities -
has gone through iterations of design in several areas
of application programming. The first attempt at a solution
has rarely been deemed adequate for true heavy-duty
professional business needs. They have guided the way
towards more robust, reliable and flexible solutions.

In the field of L<Dependency Injection|https://en.wikipedia.org/wiki/Dependency_injection>,
Java was first with its XML-based 

Perl has seen much development in the area of logging systems
and logging frameworks. Log::Dispatch were amont the first. It started with Log4Perl, inspired
by Java's Log4j, and was soon followed by others which
improved it and were more tuned to the way how Perl
as a language worked.
Log::Dispatch, ??? before Log4Perl!!!

L<Log::Any> was a great improvement over the earlier logging
frameworks and systems Perl community had built.
It streamlined the earlier and maintained compatibility
with them by providing a flexible B<Adapter> interface,
L<Log::Any::Adapter>. Its design is laudable.
The design itself: the separation of frontends and backends,
was inspired by Java's L<slf4java>.

The implementation of a logging system is always
a compromise between speed, reliability and flexibility.
You can have two of the three.
A framework, however, can provide all three. User must choose
which to pick for the implementation.

=head2 What Is In The Name And The Version?

The I<Gen2> part in the name reflects the thinking that
L<Log::Any> would have two generations: The first generation
simply implements the same functionality as other loggers.
The second generation add the feature I<context> into it.
Therefore B<Log::Any::Gen3> would be generation three.

Likewise, the versioning starts from 3.001.

=head1 DESCRIPTION

We consider that the logger must have speed when it fullfills its primary
function but it doesn't need to be fast when setting up or changing its
configuration. That function is executed rarely but when it is done,
it is necessary to get it right because a faulty configuration is dangerous
for its internal stability.

By reducing the number of logging functions and their arguments
we hope to solidify a straight and uncomplicated interface
where the interpretation of the arguments will never become
complicated and error prone.

There is a special compatiblity package which connects Log::Any to Log::Any::Gen3.


