#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket::INET;
use IO::Socket::UNIX;
use IO::Handle;

my $INET_TCP_PORT  = $ENV{LR7_IO_INET_TCP_PORT} // 5150;
my $INET_UDP_PORT  = $ENV{LR7_IO_INET_UDP_PORT} // 5151;
my $UNIX_STREAM    = '/tmp/lr7_io_unix_stream.sock';
my $UNIX_DGRAM     = '/tmp/lr7_io_unix_dgram.sock';

STDOUT->autoflush(1);

my %options = (
    1 => 'Internet TCP',
    2 => 'Internet UDP',
    3 => 'UNIX TCP',
    4 => 'UNIX UDP',
);

print "Выберите домен/протокол (IO::Socket):\n";
print " 1) Internet TCP\n 2) Internet UDP\n 3) UNIX TCP\n 4) UNIX UDP\n> ";
chomp(my $choice = <STDIN> // '');

if ($choice eq '1') {
    my $sock = IO::Socket::INET->new(
        PeerAddr => '127.0.0.1',
        PeerPort => $INET_TCP_PORT,
        Proto    => 'tcp',
    ) or die "Cannot connect TCP: $@";

    $sock->autoflush(1);
    print "Подключено к [$options{$choice}] порт $INET_TCP_PORT. exit для выхода.\n";
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        print $sock "$line\n";
        last if $line eq 'exit';
    }
    close $sock;
}
elsif ($choice eq '2') {
    my $sock = IO::Socket::INET->new(
        PeerAddr => '127.0.0.1',
        PeerPort => $INET_UDP_PORT,
        Proto    => 'udp',
    ) or die "Cannot create UDP socket: $@";

    print "Отправка UDP на порт $INET_UDP_PORT. exit для выхода.\n";
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        $sock->send($line);
        last if $line eq 'exit';
    }
    close $sock;
}
elsif ($choice eq '3') {
    my $sock = IO::Socket::UNIX->new(
        Type => SOCK_STREAM,
        Peer => $UNIX_STREAM,
    ) or die "Cannot connect UNIX stream: $@";

    $sock->autoflush(1);
    print "Подключено к $UNIX_STREAM. exit для выхода.\n";
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        print $sock "$line\n";
        last if $line eq 'exit';
    }
    close $sock;
}
elsif ($choice eq '4') {
    my $sock = IO::Socket::UNIX->new(
        Type => SOCK_DGRAM,
        Peer => $UNIX_DGRAM,
    ) or die "Cannot connect UNIX datagram: $@";

    print "Отправка датаграмм на $UNIX_DGRAM. exit для выхода.\n";
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        $sock->send($line);
        last if $line eq 'exit';
    }
    close $sock;
}
else {
    die "Неверный выбор";
}
