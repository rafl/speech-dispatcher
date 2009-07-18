use 5.010;
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
                $args->{on_connect}->($self)
                    if CodeRef->check($args->{on_connect});
            });
        }, sub { $self->connect_timeout };
    }

    method _disconnected {
        confess 'disconnected from speech server';
    }

    method _error ($, Bool $fatal, Str $message) {
        confess qq{error in communication with speech server: $message};
    }

    method send_command (:$cmd, :$args = [], :$cb) {
        weaken $self;
        $self->handle->push_write(
            join q{ } => $cmd, @{ $args }, "\r\n",
        );
        $self->_receive_reply(sub {
            my ($self, $code, $rest) = @_;
            $self->$cb($code, $rest)
                if $cb;
        });
    }

    method _parse_reply (Str $reply) {
        my ($code, $rest) = $reply =~ /^(\d+)[-\s](.*)$/;
        return ($code, $rest);
    }

    method _receive_reply (CodeRef $cb) {
        weaken $self;
        $self->handle->push_read(line => sub {
            my (undef, $msg) = @_;
            my ($code, $rest) = $self->_parse_reply($msg);

            given ($code) {
                when (/^3/)    { confess qq{Received server error $code: $rest} }
                when (/^[45]/) {
                    confess qq{Received client error $code: $rest.}
                      . ' This is most likely a bug in Speech::Dispatcher.'
                      . ' Please inform the author.'
                }
            }

            $self->$cb($code, $rest);
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
                $self->_receive_reply(sub {
                    my ($self, $code, $rest) = @_;
                    $msg_id = $rest;
                });

                $self->_receive_reply(sub {
                    my ($self, $code, $rest) = @_;
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
