package Log::Any::Gen3::Level 3.001;
use strict;
use warnings;

# ABSTRACT: Logging levels as constants.
our $VERSION = '3.001';

my @levels = qw( trace debug info warning error critical alert emergency );
my %levels = ( map { $_ => 1 } @levels );

use parent 'Exporter';
our @EXPORT = qw(); # Export nothing by default!
our @EXPORT_OK = map { uc } @levels;
our %EXPORT_TAGS = (
    levels => [ map { uc } @levels ],
);

foreach ( @levels ) {
    my $sub_name = uc $_;
    no strict 'refs'; ## no critic (TestingAndDebugging::ProhibitNoStrict)
    *$sub_name = sub { return __PACKAGE__ . q{::} . $sub_name; }
}

sub levels {
    # return map { uc } @levels;
    return @levels;
}

1;
