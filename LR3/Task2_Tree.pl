#!/usr/bin/perl
use strict;
use warnings;

# Задание 2: Упорядоченное бинарное дерево целых чисел (интерактивный режим)

my $root = undef; # Структура узла: { value => $val, left => $left, right => $right }

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
    } else {
        # дубликаты игнорируем
    }
}

sub find_min {
    my $node = shift;
    while ($node->{left}) { $node = $node->{left}; }
    return $node;
}

sub tree_delete {
    my ($node_ref, $value) = @_;
    return unless $$node_ref;
    if ($value < $$node_ref->{value}) {
        tree_delete(\$$node_ref->{left}, $value);
    } elsif ($value > $$node_ref->{value}) {
        tree_delete(\$$node_ref->{right}, $value);
    } else {
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

sub tree_print {
    my $node = shift;
    return unless $node;
    tree_print($node->{left});
    print $node->{value} . " ";
    tree_print($node->{right});
}

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
        print "OK: удалено $val\n";
    } elsif ($line =~ /^print\s*$/i) {
        print "Дерево (in-order): ";
        tree_print($root);
        print "\n";
    } elsif ($line =~ /^exit\s*$/i) {
        print "Выход.\n";
        last;
    } else {
        print "Неверная команда. Используйте: add <num> | del <num> | print | exit\n";
    }
}


