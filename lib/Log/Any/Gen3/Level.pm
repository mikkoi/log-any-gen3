package Log::Any::Gen3::Level 3.001;
use strict;
use warnings;

# ABSTRACT: Logging levels as constants.
our $VERSION = '3.001';

my @levels = qw( emergency alert critical error warning notice info debug trace );
my %levels = ( map { $_ => 1 } @levels );

# Numeric values: lower number = more severe
my %LEVEL_NUM = (
    emergency => 0,
    alert     => 1,
    critical  => 2,
    error     => 3,
    warning   => 4,
    notice    => 5,
    info      => 6,
    debug     => 7,
    trace     => 8,
);

use parent 'Exporter';
our @EXPORT = qw(); # Export nothing by default!
our @EXPORT_OK = ( ( map { uc } @levels ), 'level_num' );
our %EXPORT_TAGS = (
    levels => [ map { uc } @levels ],
);

foreach ( @levels ) {
    my $sub_name = uc $_;
    no strict 'refs'; ## no critic (TestingAndDebugging::ProhibitNoStrict)
    *$sub_name = sub { return __PACKAGE__ . q{::} . $sub_name; }
}

sub levels {
    return @levels;
}

sub level_num {
    my ($level_name) = @_;
    return $LEVEL_NUM{$level_name};
}

1;
