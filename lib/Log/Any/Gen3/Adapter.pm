package Log::Any::Gen3::Adapter 3.001;
use strict;
use warnings;

# ABSTRACT: Base class for all Adapter classes.

sub log {
    require Carp;
    Carp::croak('Sub not implemented');
}

1;
