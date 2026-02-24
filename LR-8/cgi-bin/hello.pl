#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(header);

print header('text/html; charset=UTF-8');
print "<h1>Hello, CGI!</h1>";
