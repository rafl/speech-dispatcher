use strict;
use warnings;
use Test::More;

use AnyEvent;
use Speech::Dispatcher;

my $cv = AnyEvent->condvar;

my $d = Speech::Dispatcher->new({
    on_connect => sub { $cv->send },
});
isa_ok($d, 'Speech::Dispatcher');

$cv->wait;

$cv = AnyEvent->condvar;

$d->say('foobar', sub { $cv->send });

$cv->wait;

done_testing;
