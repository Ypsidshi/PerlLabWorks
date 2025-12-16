#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);    # ключи: файл, from, to, out
use Encode qw(decode encode);       # кодовые преобразования

sub usage {
    print <<"USAGE";
Usage: perl $0 --file <input> --from <encoding> --to <encoding> [--out <output>]
    --file, -f   Input filename
    --from       Source encoding (win1251 | koi8-r | utf-8)
    --to         Target encoding (koi8-r | cp866 | utf-8)
    --out,  -o   Output filename (prints readable UTF-8 to STDOUT if omitted)
    Подсказка: авто-определения нет, указывайте корректную исходную кодировку.
USAGE
    exit 1;
}

sub prompt {
    my ($message) = @_;
    print $message;
    chomp(my $value = <STDIN>);
    return $value;
}

sub normalize_encoding {                       # приведение названий кодировок к виду Encode
    my ($enc) = @_;
    return undef unless defined $enc;
    $enc = lc $enc;
    return 'windows-1251' if $enc =~ /^(win(dows)?-?1251)$/;
    return 'koi8-r'       if $enc =~ /^koi8-?r$/;
    return 'cp866'        if $enc =~ /^(866|cp866|dos866|dos-?866)$/;
    return 'utf-8'        if $enc =~ /^utf-?8$/;
    return undef;
}

sub slurp_file {                               # чтение файла как бинарного
    my ($path) = @_;
    open my $fh, '<', $path or die "Cannot open $path: $!\n";
    binmode($fh, ':raw');
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub write_file {                               # запись в файл без перекодировки
    my ($path, $content) = @_;
    open my $fh, '>', $path or die "Cannot write $path: $!\n";
    binmode($fh, ':raw');
    print {$fh} $content;
    close $fh;
}

my ($input, $from, $to, $output);
GetOptions(
    'file|f=s' => \$input,
    'from=s'   => \$from,
    'to=s'     => \$to,
    'out|o=s'  => \$output,
) or usage();

$input ||= prompt("Enter input filename: ");
$from  ||= prompt("Enter source encoding (win1251 or koi8-r): ");
$to    ||= prompt("Enter target encoding (koi8-r or cp866): ");

$from = normalize_encoding($from);
$to   = normalize_encoding($to);

usage() unless defined $input && length $input;
-f $input or die "Input file not found: $input\n";
die "Unknown source encoding\n" unless $from;
die "Unknown target encoding\n" unless $to;

my %allowed = (
    'windows-1251-koi8-r' => 1,
    'koi8-r-cp866'        => 1,
    # Дополнительные удобные переходы для терминала/подготовки данных
    'utf-8-koi8-r'        => 1,
    'utf-8-cp866'         => 1,
    'utf-8-windows-1251'  => 1,
    'koi8-r-utf-8'        => 1,
    'windows-1251-utf-8'  => 1,
);
my $pair_key = "$from-$to";
die "Unsupported conversion for this task (allowed: win1251->koi8-r, koi8-r->cp866, plus optional utf-8 helpers)\n"
  unless $allowed{$pair_key};

my $raw      = slurp_file($input);
my $decoded  = decode($from, $raw);
my $encoded  = encode($to, $decoded);

if ($output) {
    write_file($output, $encoded);
    print "Converted file written to $output\n";
} else {
    # Для читаемого просмотра в UTF-8 терминале выводим результат обратно в UTF-8,
    # сами байты целевой кодировки можно сохранить через --out.
    binmode(STDOUT, ':encoding(UTF-8)');
    my $preview = decode($to, $encoded);
    print $preview;
    print "\n";
}
