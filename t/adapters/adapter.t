#!perl
use strict;
use warnings;
use Test2::V0;

use Log::Any::Gen3::Adapter;
use Log::Any::Gen3::Level qw( level_num );

{
    package Log::Any::Gen3::Adapter::DummyTest;
    use parent 'Log::Any::Gen3::Adapter';
    my @logged;
    sub _init {
        my ($self, %args) = @_;
        $self->{logged} = [];
    }
    sub log {
        my ($self, $level, $message, $context_href) = @_;
        push @{ $self->{logged} }, { level => $level, message => $message, context => $context_href };
    }
    sub logged { return $_[0]->{logged} }
    sub clear  { $_[0]->{logged} = [] }
}

subtest 'base adapter constructor' => sub {
    my $a = Log::Any::Gen3::Adapter::DummyTest->new(
        categories => ['cat1', 'cat2'],
        log_level  => 'warning',
    );
    is( $a->log_level, 'warning', 'log_level set correctly' );
    is( $a->categories, ['cat1', 'cat2'], 'categories set correctly' );
};

subtest 'default values' => sub {
    my $a = Log::Any::Gen3::Adapter::DummyTest->new();
    is( $a->log_level, 'trace', 'default log_level is trace' );
    is( $a->categories, [], 'default categories is empty' );
};

subtest 'accepts_category' => sub {
    my $a = Log::Any::Gen3::Adapter::DummyTest->new( categories => ['web', 'db'] );
    ok( $a->accepts_category('web'), 'accepts listed category' );
    ok( $a->accepts_category('db'),  'accepts listed category' );
    ok( !$a->accepts_category('email'), 'rejects unlisted category' );

    my $all = Log::Any::Gen3::Adapter::DummyTest->new();
    ok( $all->accepts_category('anything'), 'empty categories accepts all' );
};

subtest 'is_active level filtering' => sub {
    my $a = Log::Any::Gen3::Adapter::DummyTest->new( log_level => 'warning' );
    ok( $a->is_active('emergency'), 'emergency passes warning threshold' );
    ok( $a->is_active('error'),     'error passes warning threshold' );
    ok( $a->is_active('warning'),   'warning passes warning threshold' );
    ok( !$a->is_active('notice'),   'notice does not pass warning threshold' );
    ok( !$a->is_active('info'),     'info does not pass warning threshold' );
    ok( !$a->is_active('debug'),    'debug does not pass warning threshold' );
    ok( !$a->is_active('trace'),    'trace does not pass warning threshold' );
};

subtest 'DummyTest adapter receives log calls' => sub {
    my $a = Log::Any::Gen3::Adapter::DummyTest->new( log_level => 'trace' );
    $a->log('info', 'hello world', { key => 'val' });
    is( scalar @{ $a->logged }, 1, 'one message logged' );
    is( $a->logged->[0]{level}, 'info', 'level correct' );
    is( $a->logged->[0]{message}, 'hello world', 'message correct' );
    is( $a->logged->[0]{context}{key}, 'val', 'context correct' );
};

subtest 'base adapter log croaks' => sub {
    my $base = Log::Any::Gen3::Adapter->new();
    ok( dies { $base->log('info', 'test') }, 'base log() croaks' );
};

done_testing;
