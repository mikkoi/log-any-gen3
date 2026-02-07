#!perl
use Test2::V0;
# encoding utf8;

use Log::Any::Gen3::Proxy::Basic;
my $p = Log::Any::Gen3::Proxy::Basic->new( category => 'this_test' );

# is( $p, 'Log::Any::Gen3::Proxy::Basic', 'Correct Proxy class' );
is( $p->{config}->{adapters}->[0]->isa, 'Log::Any::Gen3::Adapter::File', 'Correct Adapter class');

done_testing;
