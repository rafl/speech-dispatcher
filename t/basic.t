use strict;
use warnings;
use Test::More;

use Speech::Dispatcher;

my $d = Speech::Dispatcher->new;
isa_ok($d, 'Speech::Dispatcher');

done_testing;
