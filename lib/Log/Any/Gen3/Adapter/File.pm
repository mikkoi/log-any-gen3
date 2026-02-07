package Log::Any::Gen3::Adapter::File 3.001;
use strict;
use warnings;

# ABSTRACT: Adapter: File

use parent 'Log::Any::Gen3::Adapter';

sub log {
    my ($lvl, $arg_1, $arg_2) = @_;
    return if( $lvl
}

1;
