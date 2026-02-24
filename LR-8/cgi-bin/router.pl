#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(param redirect);

my $action = param('action') // '';
my %targets = (
    list     => '/cgi-bin/list.pl',
    add      => '/add.html',
    search   => '/search.html',
    postcard => '/postcard.html',
    hello    => '/cgi-bin/hello.pl',
);

my $target = $targets{$action} // '/index.html';
print redirect($target);
