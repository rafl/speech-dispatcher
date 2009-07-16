use strict;
use warnings;

package Speech::Dispatcher;

use XSLoader;
use File::Basename;
use namespace::clean;

our $VERSION = '0.01';

XSLoader::load(__PACKAGE__, $VERSION);

sub new {
    my ($class, $args) = @_;

    $args = {
        client_name     => basename($0),
        connection_name => 'main',
        user_name       => (getpwuid($<))[0],
        connection_mode => 'single',
        %{ $args || {} },
    };

    return $class->_open(
        @{ $args }{qw/client_name connection_name user_name connection_mode/},
    );
}

1;
