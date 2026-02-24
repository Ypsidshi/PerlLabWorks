#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(header param redirect escapeHTML);

my %people = (
    friend   => 'друг',
    colleague=> 'коллега',
    family   => 'семья',
);
my %fest = (
    newyear   => 'С Новым годом',
    birthday  => 'С днем рождения',
    valentine => 'С Днем святого Валентина',
);
my %img = (
    newyear   => '/img/new_year.svg',
    birthday  => '/img/birthday.svg',
    valentine => '/img/valentine.svg',
);

my $sender = param('regname') // '';
if ($sender eq '') {
    print redirect('/postcard.html?err=1');
    exit;
}

my $who_key = param('who') // '';
my $holyday_key = param('holyday') // '';

my $adresat = $people{$who_key} // 'друг';
my $holyday_text = $fest{$holyday_key} // 'праздник';
my $img_src = $img{$holyday_key} // '/img/new_year.svg';

print header('text/html; charset=UTF-8');
print "<!doctype html>\n";
print "<html lang=\"ru\">\n<head>\n";
print "<meta charset=\"UTF-8\">\n";
print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n";
print "<link rel=\"stylesheet\" href=\"/styles.css\">\n";
print "<title>Открытка</title>\n</head>\n<body>\n";
print "<div class=\"container\">\n";
print "<h1>Greetings!</h1>\n";
print "<div class=\"card postcard\">\n";
print "<img class=\"postcard-img\" src=\"$img_src\" alt=\"$holyday_text\">\n";
print "<h2>Dear $adresat, $holyday_text!</h2>\n";
print "<p>Best regards, " . escapeHTML($sender) . "</p>\n";
print "</div>\n";
print "<p><a href=\"/postcard.html\">Создать еще</a> · <a href=\"/index.html\">На главную</a></p>\n";
print "</div>\n</body>\n</html>\n";
