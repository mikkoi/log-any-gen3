package Log::Any::Gen3::Proxy 3.001;
use strict;
use warnings;

# ABSTRACT: Base class for all Proxy classes.
our $VERSION = '3.001';

# my @levels = qw( trace debug info warning error critical alert emergency );
#
# use parent 'Exporter';
# our @EXPORT = qw(); # Export nothing by default!
# our @EXPORT_OK = map { uc } @levels;
# our %EXPORT_TAGS = (
#     levels => [ map { uc } @levels ],
# );

use Log::Any::Gen3::Level;

sub new {
    my ($class, %args) = @_;
    my $cat = $args{'category'};
    $cat = (caller 1)[2] if( ! defined $cat );
    # TODO Validate category!
    my %config = (
        adapters => [],
    );
    my $self = {
        config => \%config,
    };
    return bless $self, $class;
}
sub update_config {
    my ($self, %args) = @_;
    foreach my $key (keys %args) {
        $self->{config}->{$key} = $args{$key};
    }
}

foreach my $lvl ( Log::Any::Gen3::Level::levels ) {
    no strict 'refs'; ## no critic (TestingAndDebugging::ProhibitNoStrict)
    *$lvl = sub {
        # my ($self, @args) = @_;
        # $self->log( $lvl, @args );
        return $_[0]->log( $lvl, $_[1], $_[2] );
    }
}

sub log {
    my ($self, @args) = @_;
    foreach (@{ $self->{config}->{adapters} }) {
        $_->log( @args );
    }
}

1;
