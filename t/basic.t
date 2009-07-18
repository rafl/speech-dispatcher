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

$cv = AnyEvent->condvar;
$d->list_output_modules(sub {
    my ($d, @modules) = @_;
    ok(scalar grep { $_ eq 'dummy' } @modules);
    $cv->send;
});
$cv->wait;

$cv = AnyEvent->condvar;
$d->list_voices(sub {
    my ($d, @voices) = @_;
    ok(scalar grep { /male/i } @voices);
    $cv->send;
});
$cv->wait;

$cv = AnyEvent->condvar;
$d->list_synthesis_voices(sub {
    my ($d, @voices) = @_;
    $cv->send;
});
$cv->wait;

done_testing;
