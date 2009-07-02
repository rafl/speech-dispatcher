use strict;
use warnings;
use Test::More tests => 1;

BEGIN { $ENV{PERL_DL_NONLAZY} = 1 }

BEGIN { use_ok('Speech::Dispatcher') }
