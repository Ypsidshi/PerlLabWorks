#!/usr/bin/env perl
use strict;
use warnings;
use Socket qw(
  :DEFAULT
  IPPROTO_TCP IPPROTO_UDP
  PF_INET PF_UNIX
  SOCK_STREAM SOCK_DGRAM
);
use IO::Handle;

my $INET_TCP_PORT  = $ENV{LR7_INET_TCP_PORT} // 5050;
my $INET_UDP_PORT  = $ENV{LR7_INET_UDP_PORT} // 5051;
my $UNIX_STREAM    = '/tmp/lr7_unix_stream.sock';
my $UNIX_DGRAM     = '/tmp/lr7_unix_dgram.sock';

STDOUT->autoflush(1);

my %options = (
    1 => 'Internet TCP',
    2 => 'Internet UDP',
    3 => 'UNIX TCP',
    4 => 'UNIX UDP',
);

print "Выберите домен/протокол:\n";
print " 1) Internet TCP\n 2) Internet UDP\n 3) UNIX TCP\n 4) UNIX UDP\n> ";
chomp(my $choice = <STDIN> // '');

my ($domain, $type, $proto, $dest, $label);

if ($choice eq '1') {
    $domain = PF_INET;
    $type   = SOCK_STREAM;
    $proto  = IPPROTO_TCP;
    $dest   = sockaddr_in($INET_TCP_PORT, inet_aton('127.0.0.1'));
    $label  = $options{$choice};
} elsif ($choice eq '2') {
    $domain = PF_INET;
    $type   = SOCK_DGRAM;
    $proto  = IPPROTO_UDP;
    $dest   = sockaddr_in($INET_UDP_PORT, inet_aton('127.0.0.1'));
    $label  = $options{$choice};
} elsif ($choice eq '3') {
    $domain = PF_UNIX;
    $type   = SOCK_STREAM;
    $proto  = 0;
    $dest   = sockaddr_un($UNIX_STREAM);
    $label  = $options{$choice};
} elsif ($choice eq '4') {
    $domain = PF_UNIX;
    $type   = SOCK_DGRAM;
    $proto  = 0;
    $dest   = sockaddr_un($UNIX_DGRAM);
    $label  = $options{$choice};
} else {
    die "Неверный выбор";
}

socket(my $sock, $domain, $type, $proto) or die "socket: $!";

# Для UNIX datagram требуется собственный адрес отправителя.
my $tmp_unix_client;
if ($domain == PF_UNIX && $type == SOCK_DGRAM) {
    $tmp_unix_client = "/tmp/lr7_unix_dgram_client_$$.sock";
    unlink $tmp_unix_client;
    bind($sock, sockaddr_un($tmp_unix_client)) or die "bind client: $!";
}

if ($type == SOCK_STREAM) {
    connect($sock, $dest) or die "connect: $!";
    $sock->autoflush(1);
    print "Подключено к серверу [$label]. Введите текст (exit для завершения).\n";
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        print $sock "$line\n";
        last if $line eq 'exit';
    }
    close $sock;
} else {
    print "Отправка датаграмм на [$label]. Введите текст (exit для завершения).\n";
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        send($sock, $line, 0, $dest) or warn "send: $!";
        last if $line eq 'exit';
    }
    close $sock;
}

END {
    unlink $tmp_unix_client if $tmp_unix_client && -S $tmp_unix_client;
}
