#!/usr/bin/perl
use strict;
use warnings;

# Задание 1: Упорядоченный односвязный список студентов

# Структура узла: анонимный хеш { data => {fio, num, group, spec, year}, next => $next }

my $head = undef;

# Рекурсивная функция добавления элемента
sub insert_recursive {
    my ($node_ref, $new_data) = @_;
    my $new_num = $new_data->{num};

    if (!$$node_ref) {
        $$node_ref = { data => $new_data, next => undef };
        return;
    }

    if ($new_num < $$node_ref->{data}->{num}) {
        my $new_node = { data => $new_data, next => $$node_ref };
        $$node_ref = $new_node;
        return;
    }

    insert_recursive(\$$node_ref->{next}, $new_data);
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

# Пример использования для задания 1
print "Задание 1: Односвязный список студентов\n";

insert_recursive(\$head, { fio => "Иванов И.И.", num => 12345, group => "Гр1", spec => "Информатика", year => 2000 });
insert_recursive(\$head, { fio => "Петров П.П.", num => 54321, group => "Гр2", spec => "Математика", year => 2001 });
insert_recursive(\$head, { fio => "Сидоров С.С.", num => 23456, group => "Гр1", spec => "Информатика", year => 1999 });

print "Список после добавления:\n";
print_list_recursive($head, 1);

delete_recursive(\$head, 23456);
print "Список после удаления 23456:\n";
print_list_recursive($head, 1);

print "\n";

# Задание 2: Упорядоченное бинарное дерево целых чисел

# Структура узла: { value => $val, left => $left, right => $right }

my $root = undef;

# Рекурсивная функция добавления
sub tree_insert {
    my ($node_ref, $value) = @_;

    if (!$$node_ref) {
        $$node_ref = { value => $value, left => undef, right => undef };
        return;
    }

    if ($value < $$node_ref->{value}) {
        tree_insert(\$$node_ref->{left}, $value);
    } elsif ($value > $$node_ref->{value}) {
        tree_insert(\$$node_ref->{right}, $value);
    }
}

# Рекурсивная функция поиска минимального в поддереве
sub find_min {
    my $node = shift;
    while ($node->{left}) {
        $node = $node->{left};
    }
    return $node;
}

# Рекурсивная функция удаления
sub tree_delete {
    my ($node_ref, $value) = @_;

    return unless $$node_ref;

    if ($value < $$node_ref->{value}) {
        tree_delete(\$$node_ref->{left}, $value);
    } elsif ($value > $$node_ref->{value}) {
        tree_delete(\$$node_ref->{right}, $value);
    } else {
        # Узел найден
        if (!$$node_ref->{left} && !$$node_ref->{right}) {
            $$node_ref = undef;
        } elsif (!$$node_ref->{left}) {
            $$node_ref = $$node_ref->{right};
        } elsif (!$$node_ref->{right}) {
            $$node_ref = $$node_ref->{left};
        } else {
            my $min_node = find_min($$node_ref->{right});
            $$node_ref->{value} = $min_node->{value};
            tree_delete(\$$node_ref->{right}, $min_node->{value});
        }
    }
}

# Рекурсивная функция вывода (in-order)
sub tree_print {
    my $node = shift;
    return unless $node;

    tree_print($node->{left});
    print $node->{value} . " ";
    tree_print($node->{right});
}

# Демонстрация для задания 2: интерактивный режим
print "Задание 2: Бинарное дерево (интерактивный режим)\n";
print "Команды: add <num> | del <num> | print | exit\n";
while (1) {
    print "> ";
    my $line = <STDIN>;
    last unless defined $line;
    chomp $line;
    next if $line =~ /^\s*$/;

    if ($line =~ /^add\s+(-?\d+)\s*$/i) {
        my $val = $1;
        tree_insert(\$root, $val);
        print "OK: добавлено $val\n";
    } elsif ($line =~ /^del\s+(-?\d+)\s*$/i) {
        my $val = $1;
        tree_delete(\$root, $val);
        print "OK: удалено $val (если было)\n";
    } elsif ($line =~ /^print\s*$/i) {
        print "Дерево (in-order): ";
        tree_print($root);
        print "\n";
    } elsif ($line =~ /^exit\s*$/i) {
        print "Выход из режима дерева.\n\n";
        last;
    } else {
        print "Неверная команда. Используйте: add <num> | del <num> | print | exit\n";
    }
}

# Задание 3: Ханойские башни

# Стержни как массивы (диски от большого к маленькому снизу вверх)
my @A;
my @B = ();
my @C = ();

# Имя стержня по ссылке на массив
sub rod_name {
    my ($ref) = @_;
    return $ref == \@A ? 'A' : $ref == \@B ? 'B' : 'C';
}

# Функция вывода состояния
sub print_state {
    print "Состояние стержней:\n";
    print "A: " . join(' ', reverse @A) . "\n";  # reverse для показа сверху вниз
    print "B: " . join(' ', reverse @B) . "\n";
    print "C: " . join(' ', reverse @C) . "\n";
    print "\n";
}

# Рекурсивная функция Ханой
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

# Инициализация: ввод N от пользователя
print "Задание 3: Ханойские башни\n";
my $N;
while (1) {
    print "Введите количество дисков N (>=1): ";
    my $line = <STDIN>;
    last unless defined $line; # если EOF
    chomp $line;
    if ($line =~ /^\s*(\d+)\s*$/ && $1 >= 1) {
        $N = $1;
        last;
    }
    print "Некорректное значение. Повторите ввод.\n";
}

if (defined $N) {
    @A = reverse(1..$N);  # снизу вверх: N ... 1
    @B = ();
    @C = ();
    print "Запуск решения для N=$N\n";
    print_state();
    hanoi($N, \@A, \@C, \@B);
}