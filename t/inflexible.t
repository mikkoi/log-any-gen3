#!perl
use strict;
use warnings;
use Test2::V0;

use Log::Any::Gen3::Proxy::Basic ();
use Log::Any::Gen3::Adapter::File ();
use Log::Any::Gen3::Level ();

my $log;
my $output = '';
{
    open my $tmp_fh, ">", \$output or die "Cannot open in-memory fh: $!";
    my $adapter = Log::Any::Gen3::Adapter::File->new(
        categories => [ 'cat_1', 'cat_2', 'cat_3' ],
        log_level  => 'trace',
        fh         => $tmp_fh,
    );
    $log = Log::Any::Gen3::Proxy::Basic->new(
        category => 'cat_1',
        adapters => [ $adapter ],
    );
}

subtest 'end-to-end: proxy to adapter to output' => sub {
    $log->trace("Logging in level trace");
    like( $output, qr/\[trace\] Logging in level trace/, 'trace message written to file' );
};

subtest 'multiple levels' => sub {
    $output = '';
    open my $fh, ">", \$output or die;
    my $adapter = Log::Any::Gen3::Adapter::File->new(
        log_level => 'warning',
        fh        => $fh,
    );
    my $log2 = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test',
        adapters => [$adapter],
    );
    $log2->trace("should not appear");
    $log2->debug("should not appear");
    $log2->warning("should appear");
    $log2->error("should also appear");
    unlike( $output, qr/should not appear/, 'filtered levels not in output' );
    like( $output, qr/\[warning\] should appear/, 'warning level in output' );
    like( $output, qr/\[error\] should also appear/, 'error level in output' );
};

subtest 'context in output' => sub {
    $output = '';
    open my $fh, ">", \$output or die;
    my $adapter = Log::Any::Gen3::Adapter::File->new(
        log_level => 'trace',
        fh        => $fh,
    );
    my $log3 = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test',
        adapters => [$adapter],
    );
    $log3->info("request", { user => 'alice' });
    like( $output, qr/\[info\] request \{user=alice\}/, 'context appears in output' );
};

done_testing;
