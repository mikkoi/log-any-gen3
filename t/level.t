#!perl
use strict;
use warnings;
use Test2::V0;

use Log::Any::Gen3::Level qw( level_num TRACE DEBUG INFO NOTICE WARNING ERROR CRITICAL ALERT EMERGENCY );

subtest 'constants export' => sub {
    ok( defined TRACE(),     'TRACE is exported' );
    ok( defined DEBUG(),     'DEBUG is exported' );
    ok( defined INFO(),      'INFO is exported' );
    ok( defined NOTICE(),    'NOTICE is exported' );
    ok( defined WARNING(),   'WARNING is exported' );
    ok( defined ERROR(),     'ERROR is exported' );
    ok( defined CRITICAL(),  'CRITICAL is exported' );
    ok( defined ALERT(),     'ALERT is exported' );
    ok( defined EMERGENCY(), 'EMERGENCY is exported' );
};

subtest 'levels() returns all levels' => sub {
    my @levels = Log::Any::Gen3::Level::levels();
    is( scalar @levels, 9, '9 levels including notice' );
    ok( ( grep { $_ eq 'notice' } @levels ), 'notice is in the list' );
    ok( ( grep { $_ eq 'trace' } @levels ),  'trace is in the list' );
};

subtest 'level_num() ordering' => sub {
    is( level_num('emergency'), 0, 'emergency is 0' );
    is( level_num('alert'),     1, 'alert is 1' );
    is( level_num('critical'),  2, 'critical is 2' );
    is( level_num('error'),     3, 'error is 3' );
    is( level_num('warning'),   4, 'warning is 4' );
    is( level_num('notice'),    5, 'notice is 5' );
    is( level_num('info'),      6, 'info is 6' );
    is( level_num('debug'),     7, 'debug is 7' );
    is( level_num('trace'),     8, 'trace is 8' );

    ok( level_num('emergency') < level_num('trace'), 'emergency < trace' );
    ok( level_num('error') < level_num('debug'), 'error < debug' );
    is( level_num('nonexistent'), undef, 'unknown level returns undef' );
};

done_testing;
