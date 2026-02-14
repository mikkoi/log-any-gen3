package Log::Any::Gen3::Proxy::Basic 3.001;
use strict;
use warnings;

# ABSTRACT: New simplified API proxy.
our $VERSION = '3.001';

use parent 'Log::Any::Gen3::Proxy';

use Log::Any::Gen3::Level qw( level_num );

# Generate level methods: trace(), debug(), info(), notice(), warning(),
# error(), critical(), alert(), emergency()
#
# Calling conventions:
#   $log->trace("a message")              # scalar -> message
#   $log->trace(\%context)                # hashref -> context-only
#   $log->trace("message", \%context)     # scalar + hashref -> message + context
#   $log->trace("template", \@vars)       # scalar + arrayref -> template + vars

foreach my $lvl ( Log::Any::Gen3::Level::levels() ) {
    no strict 'refs'; ## no critic (TestingAndDebugging::ProhibitNoStrict)

    *{$lvl} = sub {
        my ($self, $arg_1, $arg_2) = @_;
        my ($message, $call_context);

        if (!defined $arg_1) {
            # No args: context-only log from proxy context
        }
        elsif (ref $arg_1 eq 'HASH') {
            $call_context = $arg_1;
        }
        else {
            if (defined $arg_2) {
                if (ref $arg_2 eq 'ARRAY') {
                    $message = sprintf($arg_1, @$arg_2);
                }
                elsif (ref $arg_2 eq 'HASH') {
                    $message = $arg_1;
                    $call_context = $arg_2;
                }
            }
            else {
                $message = $arg_1;
            }
        }

        # Merge proxy context with call context
        my %merged = %{ $self->{context} };
        if ($call_context) {
            @merged{ keys %$call_context } = values %$call_context;
        }
        my $ctx = %merged ? \%merged : undef;

        for my $adapter (@{ $self->{adapters} }) {
            next if !$adapter->is_active($lvl);
            $adapter->log($lvl, $message, $ctx);
        }
        return;
    };

    # Generate is_trace(), is_debug(), etc.
    my $is_method = "is_$lvl";
    *{$is_method} = sub {
        my ($self) = @_;
        for my $adapter (@{ $self->{adapters} }) {
            return 1 if $adapter->is_active($lvl);
        }
        return 0;
    };
}

1;
