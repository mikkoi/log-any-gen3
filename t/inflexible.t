#!perl
use strict;
use warnings;
use Test2::V0;

my $log;
{
    use Log::Any::Gen3::Proxy::Basic ();
    use Log::Any::Gen3::Adapter::File ();
    # use Log::Any::Gen3 qw( :log_levels );
    use Log::Any::Gen3::Level ();
    my $tmpfile_1;
    open $tmp_fh_1, ">", \$tmpfile_1;
    my $adapter = Log::Any::Gen3::Adapter::File->new(
        categories => [ 'cat_1', 'cat_2', 'cat_3', ],
        # level => $LOG_LEVEL_TRACE,
        level => Log::Any::Gen3::Levels->trace,
        filehandle => $tmp_fh_1 );
    $log_1 = Log::Any::Gen3::Proxy::Basic->new(
        category => 'cat_1',
        adapters => [ $adapter ],
    );
}

$log_1->trace("Logging in level " . Log::Any::Gen3::Levels->TRACE);
