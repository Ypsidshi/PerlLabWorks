#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);    # разбор параметров командной строки
use File::Find qw(find);            # рекурсивный обход дерева каталогов
use File::Spec;                     # построение путей в независимом виде

sub usage {
    print <<"USAGE";
Usage: perl $0 --root <directory> --sequence <text> [--insensitive]
    --root, -d        Root directory to scan
    --sequence, -s    Sequence of characters to search for
    --insensitive, -i Case-insensitive search (без учета регистра)
USAGE
    exit 1;
}

sub prompt {
    my ($message) = @_;
    print $message;
    chomp(my $value = <STDIN>);
    return $value;
}

my ($root, $sequence, $insensitive);
GetOptions(
    'root|d=s'        => \$root,
    'sequence|s=s'    => \$sequence,
    'insensitive|i!'  => \$insensitive,
) or usage();

$root     ||= prompt("Enter root directory: ");    # запросы, если не пришли ключи
$sequence ||= prompt("Enter sequence to search: ");

usage() unless defined $root && length $root;
usage() unless defined $sequence && length $sequence;
-d $root or die "Root directory not found: $root\n";

my $abs_root = File::Spec->rel2abs($root);
my @report;
my $regex = $insensitive ? qr/\Q$sequence\E/i : qr/\Q$sequence\E/;    # шаблон с/без учета регистра

print "Scanning tree under $abs_root\n";
print "[DIR] $abs_root\n";

find(
    {
        wanted => sub {
            my $path = $File::Find::name;
            return if $path eq $abs_root;    # корень уже напечатан

            my $rel   = File::Spec->abs2rel($path, $abs_root);
            my $depth = $rel eq '.' ? 0 : scalar(split(/[\/\\]/, $rel));    # глубина для отступа
            my $indent = '  ' x $depth;

            if (-d $path) {
                print($indent . "[DIR] $rel\n");
                return;
            }

            return unless -f $path;
            print($indent . "$rel\n");

            open my $fh, '<', $path or do {
                warn "Could not open $path: $!\n";    # предупреждение и продолжение обхода
                return;
            };
            binmode($fh, ':raw');
            local $/;
            my $content = <$fh>;
            close $fh;

            my $count = () = $content =~ /$regex/g;    # подсчет вхождений
            push @report, [$rel, $count] if $count;
        },
        no_chdir => 1,
    },
    $abs_root
);

if (@report) {
    print "\nReport for sequence '$sequence' ("
      . ($insensitive ? 'case-insensitive' : 'case-sensitive') . "):\n";
    for my $entry (@report) {
        my ($file, $count) = @$entry;
        print "$file : $count\n";
    }
}
else {
    print "\nNo matches found for '$sequence'.\n";
}
