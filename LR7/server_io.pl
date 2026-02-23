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
    my $server;
    my $tries = 0;
    my $port  = $INET_TCP_PORT;
    while (!$server && $tries < 5) {
        $server = IO::Socket::INET->new(
            LocalAddr => '0.0.0.0',
            LocalPort => $port,
            Proto     => 'tcp',
            Listen    => 5,
            Reuse     => 1,
        );
        last if $server;
        last if defined $ENV{LR7_IO_INET_TCP_PORT};   # не трогаем явно заданный порт
        $port = int(rand(10000)) + 40000;             # пробуем другой
        $tries++;
    }
    die "Cannot create TCP server: $@" unless $server;
    $INET_TCP_PORT = $port; # для вывода

    print "[IO::Socket $options{$choice}] сервер запущен на порту $INET_TCP_PORT\n";
    while (my $client = $server->accept) {
        $client->autoflush(1);
        print "Клиент: " . $client->peerhost . "\n";
        while (defined(my $line = <$client>)) {
            chomp $line;
            last if $line eq 'exit';
            print "Получено: $line\n";
        }
        close $client;
    }
}
elsif ($choice eq '2') {
    my $server;
    my $tries = 0;
    my $port  = $INET_UDP_PORT;
    while (!$server && $tries < 5) {
        $server = IO::Socket::INET->new(
            LocalPort => $port,
            Proto     => 'udp',
            Reuse     => 1,
        );
        last if $server;
        last if defined $ENV{LR7_IO_INET_UDP_PORT};
        $port = int(rand(10000)) + 40000;
        $tries++;
    }
    die "Cannot create UDP server: $@" unless $server;
    $INET_UDP_PORT = $port;

    print "[IO::Socket $options{$choice}] сервер запущен на порту $INET_UDP_PORT\n";
    while (1) {
        my $data;
        $server->recv($data, 1024);
        chomp $data;
        last if $data eq 'exit';
        my $peer = $server->peerhost . ':' . $server->peerport;
        print "[$peer] $data\n";
    }
}
elsif ($choice eq '3') {
    unlink $UNIX_STREAM;
    my $server = IO::Socket::UNIX->new(
        Type => SOCK_STREAM,
        Local => $UNIX_STREAM,
        Listen => 5,
    ) or die "Cannot create UNIX stream server: $@";

    print "[IO::Socket $options{$choice}] сервер запущен на $UNIX_STREAM\n";
    while (my $client = $server->accept) {
        $client->autoflush(1);
        while (defined(my $line = <$client>)) {
            chomp $line;
            last if $line eq 'exit';
            print "Получено: $line\n";
        }
        close $client;
    }
}
elsif ($choice eq '4') {
    unlink $UNIX_DGRAM;
    my $server = IO::Socket::UNIX->new(
        Type  => SOCK_DGRAM,
        Local => $UNIX_DGRAM,
    ) or die "Cannot create UNIX datagram server: $@";

    print "[IO::Socket $options{$choice}] сервер запущен на $UNIX_DGRAM\n";
    while (1) {
        my $data;
        $server->recv($data, 1024);
        chomp $data;
        last if $data eq 'exit';
        print "[unix-dgram] $data\n";
    }
}
else {
    die "Неверный выбор";
}

END {
    unlink $UNIX_STREAM if -S $UNIX_STREAM;
    unlink $UNIX_DGRAM   if -S $UNIX_DGRAM;
}
