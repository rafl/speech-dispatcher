use strict;
use warnings;

package Speech::Dispatcher;

use XSLoader;
use File::Basename;
use namespace::clean;

our $VERSION = '0.01';

XSLoader::load(__PACKAGE__, $VERSION);

sub BUILDARGS {
    my ($class, $args) = @_;

    $args = {
        client_name     => basename($0),
        connection_name => 'main',
        user_name       => (getpwuid($<))[0],
        connection_mode => 'single',
        callbacks       => {},
        %{ $args || {} },
    };

    $args->{connection_mode} = 'threaded'
        if keys %{ $args->{callbacks} };

    return $args;
}

sub new {
    my ($class, $args) = @_;
    $args = $class->BUILDARGS($args);

    my $self = $class->_open(
        @{ $args }{qw/client_name connection_name user_name connection_mode/},
    );

    $self->BUILD($args);

    return $self;
}

sub BUILD {
    my ($self, $args) = @_;
    while (my ($type, $cb) = each %{ $args->{callbacks} }) {
        $self->${\"_set_callback_${type}"}($cb);
        $self->set_notification_on($type);
    }
}

1;
