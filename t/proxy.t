#!perl
use strict;
use warnings;
use Test2::V0;

use Log::Any::Gen3::Proxy::Basic;
use Log::Any::Gen3::Adapter;

# In-memory test adapter
{
    package TestAdapter;
    use parent 'Log::Any::Gen3::Adapter';
    sub _init { $_[0]->{logged} = [] }
    sub log {
        my ($self, $level, $message, $ctx) = @_;
        push @{ $self->{logged} }, { level => $level, message => $message, context => $ctx };
    }
    sub logged { return $_[0]->{logged} }
    sub clear  { $_[0]->{logged} = [] }
}

subtest 'creation with category' => sub {
    my $p = Log::Any::Gen3::Proxy::Basic->new( category => 'my_cat' );
    isa_ok( $p, 'Log::Any::Gen3::Proxy::Basic' );
    isa_ok( $p, 'Log::Any::Gen3::Proxy' );
    is( $p->category, 'my_cat', 'category set' );
};

subtest 'logging methods exist and are callable' => sub {
    my $adapter = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test',
        adapters => [$adapter],
    );
    for my $method (qw( trace debug info notice warning error critical alert emergency )) {
        ok( $p->can($method), "$method method exists" );
        ok( $p->can("is_$method"), "is_$method method exists" );
    }
};

subtest 'arg parsing: string message' => sub {
    my $adapter = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    $p->info("hello world");
    is( $adapter->logged->[0]{message}, 'hello world', 'string message' );
    is( $adapter->logged->[0]{context}, undef, 'no context' );
};

subtest 'arg parsing: hashref context only' => sub {
    my $adapter = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    $p->info({ key => 'val' });
    is( $adapter->logged->[0]{message}, undef, 'no message' );
    is( $adapter->logged->[0]{context}{key}, 'val', 'context passed' );
};

subtest 'arg parsing: string + hashref' => sub {
    my $adapter = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    $p->info("msg", { extra => 1 });
    is( $adapter->logged->[0]{message}, 'msg', 'message present' );
    is( $adapter->logged->[0]{context}{extra}, 1, 'context present' );
};

subtest 'arg parsing: string + arrayref (template)' => sub {
    my $adapter = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    $p->info("hello %s, you are %d", ['world', 42]);
    is( $adapter->logged->[0]{message}, 'hello world, you are 42', 'template resolved' );
};

subtest 'context get/set' => sub {
    my $p = Log::Any::Gen3::Proxy::Basic->new( category => 'test' );
    is( $p->context, {}, 'default context is empty hash' );

    $p->context({ foo => 'bar' });
    is( $p->context->{foo}, 'bar', 'full context set' );

    $p->context( baz => 123 );
    is( $p->context->{baz}, 123, 'single key set' );
    is( $p->context->{foo}, 'bar', 'previous key preserved' );
};

subtest 'context merging in log calls' => sub {
    my $adapter = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    $p->context({ request_id => 'R1' });
    $p->info("msg", { extra => 'E' });
    is( $adapter->logged->[0]{context}{request_id}, 'R1', 'proxy context merged' );
    is( $adapter->logged->[0]{context}{extra}, 'E', 'call context merged' );
};

subtest 'is_level methods' => sub {
    my $adapter = TestAdapter->new( log_level => 'warning' );
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    ok( $p->is_warning, 'is_warning true at warning level' );
    ok( $p->is_error,   'is_error true at warning level' );
    ok( !$p->is_info,   'is_info false at warning level' );
    ok( !$p->is_trace,  'is_trace false at warning level' );
};

subtest 'level filtering' => sub {
    my $adapter = TestAdapter->new( log_level => 'error' );
    my $p = Log::Any::Gen3::Proxy::Basic->new(
        category => 'test', adapters => [$adapter],
    );
    $p->trace("should not appear");
    $p->error("should appear");
    is( scalar @{ $adapter->logged }, 1, 'only error-level message logged' );
    is( $adapter->logged->[0]{message}, 'should appear', 'correct message' );
};

subtest 'add/remove adapter' => sub {
    my $a1 = TestAdapter->new();
    my $a2 = TestAdapter->new();
    my $p = Log::Any::Gen3::Proxy::Basic->new( category => 'test' );
    $p->add_adapter($a1);
    $p->add_adapter($a2);
    $p->info("both");
    is( scalar @{ $a1->logged }, 1, 'adapter 1 got message' );
    is( scalar @{ $a2->logged }, 1, 'adapter 2 got message' );

    $p->remove_adapter($a1);
    $p->info("only a2");
    is( scalar @{ $a1->logged }, 1, 'adapter 1 no longer receives' );
    is( scalar @{ $a2->logged }, 2, 'adapter 2 still receives' );
};

done_testing;
