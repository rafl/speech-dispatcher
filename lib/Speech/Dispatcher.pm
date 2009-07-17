use MooseX::Declare;

class Speech::Dispatcher {
    use MooseX::Types::Moose qw/Str HashRef Bool CodeRef/;
    use MooseX::Types::Common::Numeric qw/PositiveInt/;
    use Devel::GlobalDestruction;
    use Scalar::Util 'weaken';
    use File::Basename;
    use AnyEvent::Handle;
    use AnyEvent::Socket;

    has client_name => (
        is       => 'ro',
        isa      => Str,
        required => 1,
        default  => sub { basename($0) },
    );

    has connection_name => (
        is       => 'ro',
        isa      => Str,
        required => 1,
        default  => 'main',
    );

    has user_name => (
        is       => 'ro',
        isa      => Str,
        required => 1,
        default  => sub { (getpwuid($<))[0] },
    );

    has host => (
        is       => 'ro',
        isa      => Str,
        required => 1,
        default  => sub {
            exists $ENV{SPEECHD_HOST}
                ? $ENV{SPEECHD_HOST}
                : '127.0.0.1';
        },
    );

    has port => (
        is       => 'ro',
        isa      => PositiveInt,
        required => 1,
        default  => sub {
            exists $ENV{SPEECHD_PORT}
                ? $ENV{SPEECHD_PORT}
                : 6560;
        },
    );

    has connect_timeout => (
        is       => 'ro',
        isa      => PositiveInt,
        required => 1,
        default  => 10,
    );

    has on_connect => (
        is  => 'ro',
        isa => CodeRef,
    );

    has handle => (
        is        => 'ro',
        writer    => '_set_handle',
        predicate => '_has_handle',
    );

    around _set_handle (@args) {
        confess 'connection already has a handle'
            if $self->_has_handle;
        return $self->$orig(@args);
    }

    method BUILD (HashRef $args) {
        weaken $self;
        tcp_connect $self->host, $self->port, sub {
            my ($fh) = @_;
            confess "$!" unless $fh;

            my $handle = AnyEvent::Handle->new(
                fh       => $fh,
                on_eof   => sub { $self->_disconnected },
                on_error => sub { $self->_error(@_) },
                peername => $self->host,
            );

            $self->_set_handle($handle);
            $self->_perform_handshake(sub {
                $self->_trigger('on_connect', $self);
            });
        }, sub { $self->connect_timeout };
    }

    method _disconnected {
        confess 'disconnected from speech server';
    }

    method _error ($, Bool $fatal, Str $message) {
        confess qq{error in communication with speech server: $message};
    }

    method _trigger ($cb, @args) {
        $self->$cb->(@args);
    }

    method send_command (:$cmd, :$args = [], :$cb) {
        weaken $self;
        $self->handle->push_write(
            join q{ } => $cmd, @{ $args }, "\r\n",
        );
        $self->handle->push_read(line => sub {
            my (undef, $reply) = @_;
            $self->$cb($reply)
                if $cb;
        });
    }

    method _perform_handshake (CodeRef $cb) {
        $self->send_command(
            cb   => $cb,
            cmd  => 'SET',
            args => [
                self => CLIENT_NAME =>
                join(':' => map { $self->$_ } qw/user_name client_name connection_name/),
            ],
        );
    }

    method say (Str $text, CodeRef $cb) {
        weaken $self;
        $self->send_command(
            cmd => 'SPEAK',
            cb  => sub {
                $self->handle->push_write("$text\r\n.\r\n");

                my $msg_id;
                $self->handle->push_read(line => sub {
                    my (undef, $msg) = @_;
                    $msg_id = (split '-', $msg)[1];
                });

                $self->handle->push_read(line => sub {
                    $self->$cb($msg_id);
                });
            },
        );
    }

    method DEMOLISH {
        return if in_global_destruction;
        $self->send_command(cmd => 'QUIT');
    }
}

1;
