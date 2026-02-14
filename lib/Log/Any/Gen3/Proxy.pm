package Log::Any::Gen3::Proxy 3.001;
use strict;
use warnings;

# ABSTRACT: Base class for all Proxy classes.
our $VERSION = '3.001';

use Log::Any::Gen3::Level qw( level_num );

sub new {
    my ($class, %args) = @_;
    my $cat = $args{category};
    $cat = caller(1) || caller(0) if !defined $cat;
    my $self = bless {
        category => $cat,
        adapters => $args{adapters} || [],
        context  => {},
    }, $class;
    return $self;
}

sub category {
    my ($self) = @_;
    return $self->{category};
}

sub context {
    my ($self, @args) = @_;
    if (@args == 0) {
        return $self->{context};
    }
    if (@args == 1 && ref $args[0] eq 'HASH') {
        $self->{context} = { %{ $args[0] } };
    }
    elsif (@args == 2) {
        $self->{context}{$args[0]} = $args[1];
    }
    return $self->{context};
}

sub adapters {
    my ($self) = @_;
    return $self->{adapters};
}

sub add_adapter {
    my ($self, $adapter) = @_;
    lock($self->{adapters}) if $INC{'threads/shared.pm'};
    push @{ $self->{adapters} }, $adapter;
    return;
}

sub remove_adapter {
    my ($self, $adapter) = @_;
    lock($self->{adapters}) if $INC{'threads/shared.pm'};
    $self->{adapters} = [ grep { $_ != $adapter } @{ $self->{adapters} } ];
    return;
}

sub log {
    my ($self, $level, $message, $context_href) = @_;
    for my $adapter (@{ $self->{adapters} }) {
        next if !$adapter->is_active($level);
        $adapter->log($level, $message, $context_href);
    }
    return;
}

1;
