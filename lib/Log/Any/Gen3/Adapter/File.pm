package Log::Any::Gen3::Adapter::File 3.001;
use strict;
use warnings;

# ABSTRACT: Adapter: File
our $VERSION = '3.001';

use Fcntl qw( :flock );
use Carp qw( croak );

use parent 'Log::Any::Gen3::Adapter';

sub _init {
    my ($self, %args) = @_;
    my $file = $args{file} // $args{filename};
    $self->{file} = $file;
    $self->{fh}   = $args{fh};  # optional pre-opened filehandle
    if (!defined $self->{file} && !defined $self->{fh}) {
        croak 'Either "file" or "fh" argument is required';
    }
    return;
}

sub _fh {
    my ($self) = @_;
    if (!$self->{fh}) {
        my $file = $self->{file};
        open(my $fh, '>>', $file) or croak "Cannot open file '$file': $!";
        $self->{fh} = $fh;
    }
    return $self->{fh};
}

sub file {
    my ($self) = @_;
    return $self->{file};
}

sub log {
    my ($self, $level, $message, $context_href) = @_;
    return if !$self->is_active($level);
    my $formatted = $self->_format_message($level, $message, $context_href);
    my $fh = $self->_fh();
    flock($fh, LOCK_EX);
    print {$fh} $formatted, "\n";
    flock($fh, LOCK_UN);
    return;
}

sub _format_message {
    my ($self, $level, $message, $context_href) = @_;
    my $msg = "[$level]";
    $msg .= " $message" if defined $message && length $message;
    if ($context_href && ref $context_href eq 'HASH' && %$context_href) {
        my $ctx = join ', ', map { "$_=$context_href->{$_}" }
            sort keys %$context_href;
        $msg .= " {$ctx}";
    }
    return $msg;
}

1;
