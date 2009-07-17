use strict;
use warnings;
use Test::More;

use AnyEvent;
use Speech::Dispatcher;

my $cv = AnyEvent->condvar;

my $d = Speech::Dispatcher->new({
    callbacks => {
        (map { ($_ => sub { $cv->send }) } qw/end cancel/),
    },
});

isa_ok($d, 'Speech::Dispatcher');

my @modules = $d->list_modules;
ok(scalar grep { $_ eq 'dummy' } @modules);

$d->say('foobar baz mookooh');

$cv->wait;

done_testing;
