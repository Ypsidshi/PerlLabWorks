#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket::INET;
use IO::Handle;

my $PORT = shift // 5250;

my $server = IO::Socket::INET->new(
    LocalAddr => '0.0.0.0',
    LocalPort => $PORT,
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1,
) or die "Cannot start server: $@";

STDOUT->autoflush(1);
print "Reverse сервер слушает порт $PORT (Ctrl+C для выхода)\n";

while (my $client = $server->accept) {
    $client->autoflush(1);
    print "Клиент подключен: " . $client->peerhost . "\n";
    while (defined(my $line = <$client>)) {
        chomp $line;
        my $resp = reverse $line;
        print $client "$resp\n";
        print "[echo] $line -> $resp\n";
    }
    close $client;
}
