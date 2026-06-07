#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket::INET;
use IO::Handle;

my $PORT = shift // 5250;

my $sock = IO::Socket::INET->new(
    PeerAddr => '127.0.0.1',
    PeerPort => $PORT,
    Proto    => 'tcp',
) or die "Cannot connect to server: $@";

$sock->autoflush(1);

print "Соединено с сервером на порту $PORT. Введите строки (exit для завершения).\n";

while (defined(my $line = <STDIN>)) {
    chomp $line;
    last if $line eq 'exit';
    print $sock "$line\n";
    my $resp = <$sock>;
    last unless defined $resp;
    print "Ответ: $resp";
}

close $sock;
