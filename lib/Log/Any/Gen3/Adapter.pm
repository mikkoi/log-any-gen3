package Log::Any::Gen3::Adapter 3.001;
use strict;
use warnings;

# ABSTRACT: Base class for all Adapter classes.

use Carp qw( croak );

sub log {
    croak('Sub \'log()\' not implemented');
}

sub new {
    my ($class, %args) = @_;
    my $cat = $args{'categories'};
    # TODO Validate category!
    my %config = (
    );
    my $self = {
        categories => [],
        log_level => 
        config => \%config,
    };
    return bless $self, $class;
}
1;
