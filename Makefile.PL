use strict;
use warnings;
use inc::Module::Install;

name 'Speech-Dispatcher';
all_from 'lib/Speech/Dispatcher.pm';

ppport;

requires_external_cc;
cc_lib_links('speechd');

WriteAll;
