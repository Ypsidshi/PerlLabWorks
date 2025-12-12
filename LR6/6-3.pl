#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);    # чтение параметров

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

sub roman_to_arabic {                     # конвертация римского числа в арабское
    my ($roman) = @_;
    return undef unless defined $roman && length $roman;

    my %value = (
        M => 1000, D => 500, C => 100, L => 50,
        X => 10,   V => 5,   I => 1
    );

    my @chars = split //, uc $roman;
    my $total = 0;
    for my $i (0 .. $#chars) {
    my $current = $value{$chars[$i]} || return undef;    # неверный символ -> undef
        my $next    = $value{$chars[$i + 1]} || 0;
        $total += ($current < $next) ? -$current : $current;
    }
    return $total;
}

sub slurp_file {                          # полное чтение файла
    my ($path) = @_;
    open my $fh, '<', $path or die "Cannot open $path: $!\n";
    binmode($fh, ':raw');
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub write_file {
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
my $roman_pattern = qr/\b(?i:M{0,3}(?:CM|CD|D?C{0,3})(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{0,3}))\b/;

$content =~ s/$roman_pattern/
    my $arabic = roman_to_arabic($1 // $&);
    defined $arabic ? $arabic : $&
/eg;

if ($output) {
    write_file($output, $content);
    print "Converted numbers written to $output\n";
} else {
    binmode(STDOUT, ':raw');
    print $content;
}
