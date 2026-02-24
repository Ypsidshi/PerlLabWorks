#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(header param escapeHTML);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Board::Storage qw(read_ads search_ads);

my $q = param('q') // '';
my $category = param('category') // '';
my $city = param('city') // '';

my $data_file = "$FindBin::Bin/../data/ads.tsv";
my $rows = read_ads($data_file);
my $found = search_ads($rows, $q, $category, $city);

print header('text/html; charset=UTF-8');
print "<!doctype html>\n";
print "<html lang=\"ru\">\n<head>\n";
print "<meta charset=\"UTF-8\">\n";
print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n";
print "<link rel=\"stylesheet\" href=\"/styles.css\">\n";
print "<title>Доска объявлений — поиск</title>\n</head>\n<body>\n";
print "<div class=\"container\">\n";
print "<h1>Результаты поиска</h1>\n";
print "<p><a href=\"/search.html\">Новый поиск</a> · <a href=\"/index.html\">На главную</a></p>\n";

my $q_h = escapeHTML($q);
my $cat_h = escapeHTML($category);
my $city_h = escapeHTML($city);
print "<div class=\"meta\">Запрос: <strong>$q_h</strong> Категория: <strong>$cat_h</strong> Город: <strong>$city_h</strong></div>\n";

if (!@$found) {
    print "<p>Ничего не найдено.</p>\n";
} else {
    print "<div class=\"cards\">\n";
    for my $r (@$found) {
        my $title = escapeHTML($r->{title});
        my $category = escapeHTML($r->{category});
        my $price = escapeHTML($r->{price});
        my $city = escapeHTML($r->{city});
        my $contact = escapeHTML($r->{contact});
        my $desc = escapeHTML($r->{description});
        my $date = escapeHTML($r->{date});
        print "<div class=\"card\">\n";
        print "<h3>$title</h3>\n";
        print "<div class=\"meta\">$category · $city · $date</div>\n";
        print "<div class=\"price\">$price ₽</div>\n" if $price ne '';
        print "<p>$desc</p>\n" if $desc ne '';
        print "<div class=\"contact\">Контакт: $contact</div>\n" if $contact ne '';
        print "</div>\n";
    }
    print "</div>\n";
}

print "</div>\n</body>\n</html>\n";
