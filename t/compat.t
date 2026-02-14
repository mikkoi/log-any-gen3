#!perl
use strict;
use warnings;
use Test2::V0;

use Log::Any::Gen3::Proxy::Compat;
use Log::Any::Gen3::Adapter;

{
    package CompatTestAdapter;
    use parent 'Log::Any::Gen3::Adapter';
    sub _init { $_[0]->{logged} = [] }
    sub log {
        my ($self, $level, $message, $ctx) = @_;
        push @{ $self->{logged} }, { level => $level, message => $message, context => $ctx };
    }
    sub logged { return $_[0]->{logged} }
    sub clear  { $_[0]->{logged} = [] }
}

subtest 'creation' => sub {
    my $p = Log::Any::Gen3::Proxy::Compat->new( category => 'compat_test' );
    isa_ok( $p, 'Log::Any::Gen3::Proxy::Compat' );
    isa_ok( $p, 'Log::Any::Gen3::Proxy' );
    is( $p->category, 'compat_test', 'category set' );
};

subtest 'simple methods' => sub {
    my $adapter = CompatTestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
    );
    for my $method (qw( trace debug info notice warning error critical alert emergency )) {
        ok( $p->can($method), "$method exists" );
        ok( $p->can("${method}f"), "${method}f exists" );
        ok( $p->can("is_$method"), "is_$method exists" );
    }
};

subtest 'simple log joins args' => sub {
    my $adapter = CompatTestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
    );
    $p->info('hello', 'world');
    is( $adapter->logged->[0]{message}, 'hello world', 'args joined with space' );
};

subtest 'formatted log' => sub {
    my $adapter = CompatTestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
    );
    $p->infof('count: %d, name: %s', 42, 'foo');
    is( $adapter->logged->[0]{message}, 'count: 42, name: foo', 'sprintf formatting' );
};

subtest 'aliases' => sub {
    my $adapter = CompatTestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
    );

    ok( $p->can('warn'),   'warn alias exists' );
    ok( $p->can('err'),    'err alias exists' );
    ok( $p->can('crit'),   'crit alias exists' );
    ok( $p->can('fatal'),  'fatal alias exists' );
    ok( $p->can('inform'), 'inform alias exists' );

    ok( $p->can('warnf'),   'warnf alias exists' );
    ok( $p->can('errf'),    'errf alias exists' );
    ok( $p->can('critf'),   'critf alias exists' );
    ok( $p->can('fatalf'),  'fatalf alias exists' );
    ok( $p->can('informf'), 'informf alias exists' );

    ok( $p->can('is_warn'),   'is_warn alias exists' );
    ok( $p->can('is_err'),    'is_err alias exists' );
    ok( $p->can('is_crit'),   'is_crit alias exists' );
    ok( $p->can('is_fatal'),  'is_fatal alias exists' );
    ok( $p->can('is_inform'), 'is_inform alias exists' );

    $p->warn('test warning');
    is( $adapter->logged->[0]{level}, 'warning', 'warn maps to warning level' );
};

subtest 'prefix support' => sub {
    my $adapter = CompatTestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
        prefix => '[MyApp] ',
    );
    $p->info('starting');
    is( $adapter->logged->[0]{message}, '[MyApp] starting', 'prefix prepended' );

    $adapter->clear;
    $p->infof('count: %d', 5);
    is( $adapter->logged->[0]{message}, '[MyApp] count: 5', 'prefix on formatted too' );
};

subtest 'is_level methods' => sub {
    my $adapter = CompatTestAdapter->new( log_level => 'error' );
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
    );
    ok( $p->is_error, 'is_error true' );
    ok( !$p->is_info, 'is_info false' );
};

subtest 'notice level' => sub {
    my $adapter = CompatTestAdapter->new( log_level => 'trace' );
    my $p = Log::Any::Gen3::Proxy::Compat->new(
        category => 'test', adapters => [$adapter],
    );
    $p->notice('a notice');
    is( $adapter->logged->[0]{level}, 'notice', 'notice level works' );
};

done_testing;
