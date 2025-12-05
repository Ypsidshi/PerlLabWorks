#!/usr/bin/perl
use strict;
use warnings;

# Задание 3: Ханойские башни с вводом N и пошаговой иллюстрацией

my @A;
my @B = ();
my @C = ();

sub print_state {
    print "Состояние стержней:\n";
    print "A: " . join(' ', reverse @A) . "\n";
    print "B: " . join(' ', reverse @B) . "\n";
    print "C: " . join(' ', reverse @C) . "\n";
    print "\n";
}

sub rod_name {
    my ($ref) = @_;
    return $ref == \@A ? 'A' : $ref == \@B ? 'B' : 'C';
}

sub hanoi {
    my ($n, $from, $to, $aux) = @_;
    if ($n == 1) {
        my $disk = pop @$from;
        push @$to, $disk;
        print "Перенос диска диаметра $disk со стержня " . rod_name($from) . " на " . rod_name($to) . "\n";
        sleep(1);
        print_state();
        return;
    }
    hanoi($n - 1, $from, $aux, $to);
    my $disk = pop @$from;
    push @$to, $disk;
    print "Перенос диска диаметра $disk со стержня " . rod_name($from) . " на " . rod_name($to) . "\n";
    sleep(1);
    print_state();
    hanoi($n - 1, $aux, $to, $from);
}

print "Задание 3: Ханойские башни\n";
my $N;
while (1) {
    print "Введите количество дисков N (>=1): ";
    my $line = <STDIN>;
    last unless defined $line;
    chomp $line;
    if ($line =~ /^\s*(\d+)\s*$/ && $1 >= 1) {
        $N = $1; last;
    }
    print "Некорректное значение. Повторите ввод.\n";
}

if (defined $N) {
    @A = reverse(1..$N);
    @B = ();
    @C = ();
    print "Запуск решения для N=$N\n";
    print_state();
    hanoi($N, \@A, \@C, \@B);
}


