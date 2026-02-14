package Log::Any::Gen3::Proxy::Compat 3.001;
use strict;
use warnings;

# ABSTRACT: Log::Any-compatible drop-in proxy.
our $VERSION = '3.001';

use parent 'Log::Any::Gen3::Proxy';

use Log::Any::Gen3::Level qw( level_num );
use Scalar::Util qw( blessed );

sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    $self->{prefix} = $args{prefix} // '';
    $self->{filter} = $args{filter};  # optional coderef
    return $self;
}

sub prefix {
    my ($self, @args) = @_;
    if (@args) {
        $self->{prefix} = $args[0];
    }
    return $self->{prefix};
}

sub filter {
    my ($self, @args) = @_;
    if (@args) {
        $self->{filter} = $args[0];
    }
    return $self->{filter};
}

# Generate methods for each level:
#   trace(@parts), tracef($fmt, @args), is_trace()
foreach my $lvl ( Log::Any::Gen3::Level::levels() ) {
    no strict 'refs'; ## no critic (TestingAndDebugging::ProhibitNoStrict)

    # Simple method: join args with space
    *{$lvl} = sub {
        my ($self, @parts) = @_;
        my $context_href;
        if (@parts && ref $parts[-1] eq 'HASH') {
            $context_href = pop @parts;
        }
        my $message = join(' ', @parts);
        $message = $self->{prefix} . $message if length $self->{prefix};
        if ($self->{filter}) {
            $message = $self->{filter}->($message);
            return if !defined $message;
        }
        # Merge proxy context
        my %merged = %{ $self->{context} };
        if ($context_href) {
            @merged{ keys %$context_href } = values %$context_href;
        }
        my $ctx = %merged ? \%merged : undef;
        for my $adapter (@{ $self->{adapters} }) {
            next if !$adapter->is_active($lvl);
            $adapter->log($lvl, $message, $ctx);
        }
        return;
    };

    # Formatted method: sprintf
    my $fmt_method = "${lvl}f";
    *{$fmt_method} = sub {
        my ($self, $fmt, @args) = @_;
        # Stringify refs in args
        @args = map { ref $_ ? _stringify_ref($_) : $_ } @args;
        my $message = sprintf($fmt, @args);
        $message = $self->{prefix} . $message if length $self->{prefix};
        if ($self->{filter}) {
            $message = $self->{filter}->($message);
            return if !defined $message;
        }
        my $ctx = %{ $self->{context} } ? { %{ $self->{context} } } : undef;
        for my $adapter (@{ $self->{adapters} }) {
            next if !$adapter->is_active($lvl);
            $adapter->log($lvl, $message, $ctx);
        }
        return;
    };

    # is_level method
    my $is_method = "is_$lvl";
    *{$is_method} = sub {
        my ($self) = @_;
        for my $adapter (@{ $self->{adapters} }) {
            return 1 if $adapter->is_active($lvl);
        }
        return 0;
    };
}

# Aliases matching Log::Any::Proxy
*warn    = \&warning;
*err     = \&error;
*crit    = \&critical;
*fatal   = \&critical;
*inform  = \&info;

*warnf   = \&warningf;
*errf    = \&errorf;
*critf   = \&criticalf;
*fatalf  = \&criticalf;
*informf = \&infof;

*is_warn   = \&is_warning;
*is_err    = \&is_error;
*is_crit   = \&is_critical;
*is_fatal  = \&is_critical;
*is_inform = \&is_info;

sub _stringify_ref {
    my ($ref) = @_;
    if (blessed($ref) && $ref->can('stringify')) {
        return $ref->stringify();
    }
    return "$ref";
}

1;
