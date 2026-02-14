package Log::Any::Gen3::Adapter 3.001;
use strict;
use warnings;

# ABSTRACT: Base class for all Adapter classes.
our $VERSION = '3.001';

use Carp qw( croak );
use Log::Any::Gen3::Level qw( level_num );

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        categories => $args{categories} || [],
        log_level  => $args{log_level}  || 'trace',
    }, $class;
    $self->_init(%args);
    return $self;
}

# Subclasses can override to handle extra args
sub _init { }

sub log_level {
    my ($self, @args) = @_;
    if (@args) {
        $self->{log_level} = $args[0];
    }
    return $self->{log_level};
}

sub categories {
    my ($self) = @_;
    return $self->{categories};
}

sub accepts_category {
    my ($self, $cat) = @_;
    my $cats = $self->{categories};
    return 1 if !@$cats;  # empty = accept all
    for my $c (@$cats) {
        return 1 if $c eq $cat;
    }
    return 0;
}

sub is_active {
    my ($self, $level) = @_;
    my $threshold = level_num($self->{log_level});
    my $incoming  = level_num($level);
    return 0 if !defined $threshold || !defined $incoming;
    return $incoming <= $threshold;
}

sub log {
    croak('Sub \'log()\' not implemented');
}

1;
