#!/usr/bin/perl
use strict;
use warnings;

# Задание 1: Упорядоченный односвязный список студентов

# Структура узла: анонимный хеш { data => {fio, num, group, spec, year}, next => $next }

my $head = undef;

# Рекурсивная проверка существования номера зачетки
sub exists_num {
    my ($node, $num) = @_;
    return 0 unless $node;
    return 1 if $node->{data}->{num} == $num;
    return exists_num($node->{next}, $num);
}

# Рекурсивная функция добавления элемента
sub insert_recursive {
    my ($node_ref, $new_data) = @_;
    my $new_num = $new_data->{num};

    if (!$$node_ref) {
        $$node_ref = { data => $new_data, next => undef };
        return 1;
    }

    if ($new_num == $$node_ref->{data}->{num}) {
        return 0; # дубликат
    }

    if ($new_num < $$node_ref->{data}->{num}) {
        my $new_node = { data => $new_data, next => $$node_ref };
        $$node_ref = $new_node;
        return 1;
    }

    return insert_recursive(\$$node_ref->{next}, $new_data);
}

# Рекурсивная функция удаления элемента по номеру зачетки
sub delete_recursive {
    my ($node_ref, $num) = @_;

    if (!$$node_ref) {
        return 0; # Не найдено
    }

    if ($$node_ref->{data}->{num} == $num) {
        $$node_ref = $$node_ref->{next};
        return 1; # Удалено
    }

    return delete_recursive(\$$node_ref->{next}, $num);
}

# Рекурсивная функция вывода списка в таблицу
sub print_list_recursive {
    my ($node, $is_header) = @_;
    if ($is_header) {
        printf "%-20s %-10s %-10s %-20s %-4s\n", "ФИО", "Зачетка", "Группа", "Специальность", "Год";
        print "-" x 70 . "\n";
    }
    return unless $node;

    printf "%-20s %-10d %-10s %-20s %-4d\n",
        $node->{data}->{fio},
        $node->{data}->{num},
        $node->{data}->{group},
        $node->{data}->{spec},
        $node->{data}->{year};

    print_list_recursive($node->{next}, 0);
}

print "Задание 1: Односвязный список студентов (интерактивный режим)\n";
print "Команды: add | del <num> | print | exit\n";

while (1) {
    print "> ";
    my $line = <STDIN>;
    last unless defined $line;
    chomp $line;
    next if $line =~ /^\s*$/;

    if ($line =~ /^add\s*$/i) {
        my %s;
        print "ФИО: "; my $fio = <STDIN>; last unless defined $fio; chomp $fio;
        print "Номер зачетки (целое): "; my $num = <STDIN>; last unless defined $num; chomp $num;
        print "Группа: "; my $group = <STDIN>; last unless defined $group; chomp $group;
        print "Специальность: "; my $spec = <STDIN>; last unless defined $spec; chomp $spec;
        print "Год рождения (YYYY): "; my $year = <STDIN>; last unless defined $year; chomp $year;

        if ($fio eq '' || $group eq '' || $spec eq '' || $num !~ /^\d+$/ || $year !~ /^\d{4}$/) {
            print "Ошибка: проверьте корректность полей.\n";
            next;
        }
        if (exists_num($head, $num)) {
            print "Ошибка: студент с номером $num уже существует.\n";
            next;
        }
        my $ok = insert_recursive(\$head, { fio => $fio, num => 0 + $num, group => $group, spec => $spec, year => 0 + $year });
        print $ok ? "OK: добавлен.\n" : "Ошибка: дубликат.\n";

    } elsif ($line =~ /^del\s+(\d+)\s*$/i) {
        my $num = 0 + $1;
        my $removed = delete_recursive(\$head, $num);
        print $removed ? "OK: удален $num.\n" : "Не найден $num.\n";

    } elsif ($line =~ /^print\s*$/i) {
        if (!$head) { print "Список пуст.\n"; next; }
        print_list_recursive($head, 1);

    } elsif ($line =~ /^exit\s*$/i) {
        print "Выход.\n";
        last;

    } else {
        print "Неверная команда. Используйте: add | del <num> | print | exit\n";
    }
}
