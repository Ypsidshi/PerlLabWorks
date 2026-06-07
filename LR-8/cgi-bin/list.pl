#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(header escapeHTML);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Board::Storage qw(read_ads);

my $data_file = "$FindBin::Bin/../data/ads.tsv";
my $rows = read_ads($data_file);

print header('text/html; charset=UTF-8');
print "<!doctype html>\n";
print "<html lang=\"ru\">\n<head>\n";
print "<meta charset=\"UTF-8\">\n";
print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n";
print "<link rel=\"stylesheet\" href=\"/styles.css\">\n";
print "<title>Доска объявлений — список</title>\n</head>\n<body>\n";
print "<div class=\"container\">\n";
print "<h1>Все объявления</h1>\n";
print "<p><a href=\"/index.html\">На главную</a></p>\n";

if (!@$rows) {
    print "<p>Объявлений пока нет.</p>\n";
} else {
    print "<div class=\"cards\">\n";
    for my $r (reverse @$rows) {
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
