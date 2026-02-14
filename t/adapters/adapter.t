#!perl
use strict;
use warnings;
use Test2::V0;

{
    package Log::Any::Gen3::Adapter::DummyTest;
    use parent 'Log::Any::Gen3::Adapter';
    sub new {
        my ($class, %args) = @_;
        SUPER:new('Log::Any::Gen3::Adapter', %args);
    }
    sub log {
        my ($self, $logging_level, $arg_1, $arg_2) = @_;
        return if( $logging_level > $self->{'log_level'} );
        my $msg = $self->_format_message($arg_1, $arg_2);
        print { $self->handle } $msg, "\n";
    }
    1;
}

subtest 'Simple' => sub {

    done_testing;
};

done_testing;
