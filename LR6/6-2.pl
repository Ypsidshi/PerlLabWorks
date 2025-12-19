#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);    # аргументы: входной файл и необязательный выход

sub usage {
    print <<"USAGE";
Usage: perl $0 --file <input> [--out <output>]
    --file, -f   Input filename
    --out,  -o   Output filename (prints to STDOUT if omitted)
USAGE
    exit 1;
}

sub prompt {
    my ($message) = @_;
    print $message;
    chomp(my $value = <STDIN>);
    return $value;
}

sub arabic_to_roman {                    # перевод арабского числа (1..3999) в римскую форму
    my ($number) = @_;
    return undef if !defined $number || $number < 1 || $number > 3999;

    my @values = (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1);    # номиналы
    my @roman  = qw(M CM D CD C XC L XL X IX V IV I);                       # соответствующие символы
    my $result = q{};

    for my $i (0 .. $#values) {
        while ($number >= $values[$i]) {
            $result .= $roman[$i];
            $number -= $values[$i];
        }
    }
    return $result;
}

sub slurp_file {                         # чтение файла в бинарном режиме без изменений
    my ($path) = @_;
    open my $fh, '<', $path or die "Cannot open $path: $!\n";
    binmode($fh, ':raw');
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub write_file {                         # сохранение результата в файл
    my ($path, $content) = @_;
    open my $fh, '>', $path or die "Cannot write $path: $!\n";
    binmode($fh, ':raw');
    print {$fh} $content;
    close $fh;
}

my ($input, $output);
GetOptions(
    'file|f=s' => \$input,
    'out|o=s'  => \$output,
) or usage();

$input ||= prompt("Enter input filename: ");
usage() unless defined $input && length $input;
-f $input or die "Input file not found: $input\n";

my $content = slurp_file($input);
# \b ограничивает числа целыми словами, чтобы не трогать цифры внутри слов
$content =~ s/\b(\d+)\b/
    my $roman = arabic_to_roman($1);
    defined $roman ? $roman : $1;
/eg;

if ($output) {
    write_file($output, $content);
    print "Converted numbers written to $output\n";
} else {
    binmode(STDOUT, ':raw');
    print $content;
}
