#!/usr/bin/env perl
use strict;
use warnings;
use Socket qw(
  :DEFAULT
  IPPROTO_TCP IPPROTO_UDP
  PF_INET PF_UNIX
  SOCK_STREAM SOCK_DGRAM
  SOL_SOCKET SO_REUSEADDR
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

my ($domain, $type, $proto, $sockaddr, $label);

if ($choice eq '1') {
    $domain   = PF_INET;
    $type     = SOCK_STREAM;
    $proto    = IPPROTO_TCP;
    $sockaddr = sockaddr_in($INET_TCP_PORT, INADDR_ANY);
    $label    = $options{$choice};
} elsif ($choice eq '2') {
    $domain   = PF_INET;
    $type     = SOCK_DGRAM;
    $proto    = IPPROTO_UDP;
    $sockaddr = sockaddr_in($INET_UDP_PORT, INADDR_ANY);
    $label    = $options{$choice};
} elsif ($choice eq '3') {
    $domain   = PF_UNIX;
    $type     = SOCK_STREAM;
    $proto    = 0;
    unlink $UNIX_STREAM;
    $sockaddr = sockaddr_un($UNIX_STREAM);
    $label    = $options{$choice};
} elsif ($choice eq '4') {
    $domain   = PF_UNIX;
    $type     = SOCK_DGRAM;
    $proto    = 0;
    unlink $UNIX_DGRAM;
    $sockaddr = sockaddr_un($UNIX_DGRAM);
    $label    = $options{$choice};
} else {
    die "Неверный выбор";
}

socket(my $server, $domain, $type, $proto) or die "socket: $!";
setsockopt($server, SOL_SOCKET, SO_REUSEADDR, 1) if $domain == PF_INET && $type == SOCK_STREAM;
bind($server, $sockaddr) or die "bind: $!";

if ($type == SOCK_STREAM) {
    listen($server, SOMAXCONN) or die "listen: $!";
    print "[$label] сервер запущен. Ожидание соединения...\n";
    while (accept(my $client_sock, $server)) {
        $client_sock->autoflush(1);
        my $peer_info = $domain == PF_INET
            ? inet_ntoa((sockaddr_in(getpeername($client_sock)))[1])
            : 'unix-peer';
        print "Клиент подключен: $peer_info\n";
        while (defined(my $line = <$client_sock>)) {
            chomp $line;
            last if $line eq 'exit';
            print "Получено: $line\n";
        }
        close $client_sock;
        print "Соединение закрыто\n";
    }
} else {
    print "[$label] сервер запущен. Ожидание датаграмм...\n";
    my $buf;
    while (1) {
        my $peer = recv($server, $buf, 1024, 0) or next;
        chomp $buf;
        last if $buf eq 'exit';
        if ($domain == PF_INET) {
            my ($port, $addr) = sockaddr_in($peer);
            my $ip = inet_ntoa($addr);
            print "[$ip:$port] $buf\n";
        } else {
            my $path = sockaddr_un($peer);
            print "[$path] $buf\n";
        }
    }
}

END {
    unlink $UNIX_STREAM if defined $UNIX_STREAM && -S $UNIX_STREAM;
    unlink $UNIX_DGRAM  if defined $UNIX_DGRAM  && -S $UNIX_DGRAM;
}
