#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(header param escapeHTML);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Board::Storage qw(append_ad);

my %ad = (
    title       => param('title') // '',
    category    => param('category') // '',
    price       => param('price') // '',
    city        => param('city') // '',
    contact     => param('contact') // '',
    description => param('description') // '',
);

my @missing;
push @missing, 'Название'   if $ad{title} eq '';
push @missing, 'Категория'  if $ad{category} eq '';
push @missing, 'Город'      if $ad{city} eq '';
push @missing, 'Контакт'    if $ad{contact} eq '';

print header('text/html; charset=UTF-8');
print "<!doctype html>\n";
print "<html lang=\"ru\">\n<head>\n";
print "<meta charset=\"UTF-8\">\n";
print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n";
print "<link rel=\"stylesheet\" href=\"/styles.css\">\n";
print "<title>Доска объявлений — добавление</title>\n</head>\n<body>\n";
print "<div class=\"container\">\n";
print "<h1>Добавление объявления</h1>\n";

if (@missing) {
    my $list = join(', ', @missing);
    print "<p class=\"error\">Не заполнены поля: $list</p>\n";
    print "<p><a href=\"/add.html\">Вернуться к форме</a></p>\n";
} else {
    my $data_file = "$FindBin::Bin/../data/ads.tsv";
    my ($id, $err) = append_ad($data_file, \%ad);
    if ($err) {
        print "<p class=\"error\">$err</p>\n";
    } else {
        my $title = escapeHTML($ad{title});
        print "<p class=\"success\">Объявление добавлено. ID: <strong>$id</strong></p>\n";
        print "<p>Название: $title</p>\n";
        print "<p><a href=\"/cgi-bin/list.pl\">Посмотреть все объявления</a></p>\n";
    }
    print "<p><a href=\"/index.html\">На главную</a></p>\n";
}

print "</div>\n</body>\n</html>\n";
