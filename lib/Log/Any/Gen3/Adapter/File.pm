package Log::Any::Gen3::Adapter::File 3.001;
use strict;
use warnings;

# ABSTRACT: Adapter: File

use parent 'Log::Any::Gen3::Adapter';

sub log {
    my ($self, $lvl, $arg_1, $arg_2) = @_;
    return if( $lvl < $self->level );
    my $msg = $self->_format_message($arg_1, $arg_2);
    print { $self->handle } $msg, "\n";
}

sub _build_handle {
    my $self = shift;
    my $file = $self->file;
    open( my $fh, '>>', $file ) or die "Cannot open file '$file': $!";
    return $fh;
}

sub _build_level {
    return 'trace';
}

sub _build_file {
    die "file attribute is required";
}
sub BUILDARGS {
    my $class = shift;
    my %args = @_;
    if( exists $args{filename} ) {
        $args{file} = delete $args{filename};
    }
    return $class->SUPER::BUILDARGS(%args);
}
sub _build_formatter {
    my $self = shift;
    return $self->formatter_class->new(
        prefix => $self->prefix,
        suffix => $self->suffix,
    );
}
sub _build_formatter_class {
    return 'Log::Any::Gen3::Adapter::File::Formatter';
}
__PACKAGE__->mk_accessors(qw( handle file ));
__PACKAGE__->mk_ro_accessors(qw( formatter formatter_class ));
__PACKAGE__->mk_accessors(qw( level ));sub _build_prefix {
    return '';
}

sub _build_suffix {
    return '';
}
sub _format_message {
    my ($self, $arg_1, $arg_2) = @_;
    return $self->formatter->format($arg_1, $arg_2);
}

1;
