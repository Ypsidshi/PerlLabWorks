#!/usr/bin/perl

# Основная программа

use strict;
use warnings;
use lib '.';    
use Supplier;     # Импортируем класс Supplier

my $head = undef; # Голова связанного списка поставщиков (изначально пуст)

# Вспомогательная функция для безопасного ввода числа
sub get_numeric_input {
    my ($prompt, $allow_zero) = @_;
    $allow_zero //= 0;
    
    while (1) {
        print $prompt;
        chomp(my $input = <>);
        
        # Проверяем, что ввод является числом
        if (defined $input && $input =~ /^-?\d+$/) {
            my $number = int($input);
            if ($allow_zero) {
                return $number if $number >= 0;
                print "Число должно быть неотрицательным. Попробуйте снова.\n";
            } else {
                return $number if $number > 0;
                print "Число должно быть положительным. Попробуйте снова.\n";
            }
        } else {
            print "Пожалуйста, введите корректное число. Попробуйте снова.\n";
        }
    }
}

# Вспомогательная функция для безопасного ввода текста
sub get_text_input {
    my ($prompt, $required) = @_;
    $required //= 1;
    
    while (1) {
        print $prompt;
        chomp(my $input = <>);
        
        if (defined $input && $input =~ /\S/) {
            return $input;
        } elsif (!$required) {
            return '';
        } else {
            print "Это поле обязательно для заполнения. Попробуйте снова.\n";
        }
    }
}

# Вспомогательная функция для ввода оценок
sub get_scores_input {
    print "Введите оценки через пробел: ";
    chomp(my $scores_input = <>);
    
    if (defined $scores_input && $scores_input =~ /\S/) {
        my @scores = split(' ', $scores_input);
        
        # Проверяем, что все оценки - числа
        foreach my $score (@scores) {
            unless ($score =~ /^-?\d*\.?\d+$/) {
                print "Оценка '$score' не является числом. Будут использованы только числовые оценки.\n";
                # Фильтруем только числовые оценки
                @scores = grep { /^-?\d*\.?\d+$/ } @scores;
                last;
            }
        }
        
        return @scores;
    } else {
        return ();  # Пустой массив, если ввод пустой
    }
}

# Функция добавления поставщика
sub add_supplier {
    print "\n--- Добавление нового поставщика ---\n";
    
    my $id = get_numeric_input("Введите номер поставщика: ");
    
    # Проверяем, нет ли уже поставщика с таким ID
    if ($head && $head->find_supplier($id)) {
        print "Поставщик с номером $id уже существует в списке.\n";
        return $head;
    }
    
    my $name = get_text_input("Введите название: ");
    my $category = get_text_input("Введите категорию: ");
    my $spec = get_text_input("Введите специализацию: ");
    my $founding = get_numeric_input("Введите год основания: ", 1);
    
    # Проверяем, что год основания не в будущем
    my $current_year = 1900 + (localtime)[5];
    if ($founding > $current_year) {
        print "Предупреждение: год основания ($founding) больше текущего года ($current_year).\n";
    }
    
    my @scores = get_scores_input();
    
    # Создаем новый объект Supplier с обработкой ошибок
    my $supplier;
    eval {
        $supplier = Supplier->new($id, $name, $category, $spec, $founding, @scores);
        1;
    } or do {
        my $error = $@ || 'Неизвестная ошибка';
        print "Ошибка при создании поставщика: $error";
        return $head;
    };
    
    # Добавляем в список
    eval {
        $head = $head ? $head->append($supplier) : $supplier;
        print "Поставщик '$name' успешно добавлен.\n";
        1;
    } or do {
        my $error = $@ || 'Неизвестная ошибка';
        print "Ошибка при добавлении поставщика: $error";
    };
    
    return $head;
}

# Функция удаления поставщика
sub delete_supplier {
    print "\n--- Удаление поставщика ---\n";
    
    unless ($head) {
        print "Список поставщиков пуст.\n";
        return undef;
    }
    
    print "Текущий список поставщиков:\n";
    $head->print_list();
    
    my $value = get_numeric_input("Введите номер поставщика для удаления: ");
    
    # Проверяем наличие поставщика
    my $found = $head->find_supplier($value);
    if ($found) {
        # Подтверждение удаления
        print "Вы действительно хотите удалить поставщика '", $found->{name}, "' (ID: $value)? [y/N]: ";
        chomp(my $confirm = <>);
        
        if ($confirm =~ /^y(es)?$/i) {
            $head = $head->my_delete($value);
            print "Поставщик с номером $value успешно удален.\n";
        } else {
            print "Удаление отменено.\n";
        }
    } else {
        print "Поставщик с номером $value не найден в списке.\n";
    }
    
    return $head;
}

# Функция сравнения поставщиков
sub compare_suppliers {
    print "\n--- Сравнение поставщиков ---\n";
    
    unless ($head) {
        print "Список поставщиков пуст.\n";
        return;
    }
    
    # Показываем текущий список для удобства
    print "Текущий список поставщиков:\n";
    $head->print_list();
    
    my $id1 = get_numeric_input("Введите номер первого поставщика: ");
    my $id2 = get_numeric_input("Введите номер второго поставщика: ");
    
    if ($id1 == $id2) {
        print "Нельзя сравнивать поставщика с самим собой.\n";
        return;
    }
    
    my $supplier1 = $head->find_supplier($id1);
    my $supplier2 = $head->find_supplier($id2);
    
    if ($supplier1 && $supplier2) {
        eval {
            my $result = Supplier::compare($supplier1, $supplier2);
            print "\nРезультат сравнения:\n$result";
            1;
        } or do {
            my $error = $@ || 'Неизвестная ошибка';
            print "Ошибка при сравнении поставщиков: $error";
        };
    } else {
        print "Один из поставщиков не найден:\n";
        print "Поставщик с номером $id1 " . ($supplier1 ? "найден" : "не найден") . "\n";
        print "Поставщик с номером $id2 " . ($supplier2 ? "найден" : "не найден") . "\n";
    }
}

# Функция отображения статистики
sub show_statistics {
    unless ($head) {
        print "Список поставщиков пуст.\n";
        return;
    }
    
    my $size = $head->size();
    print "\n--- Статистика ---\n";
    print "Всего поставщиков: $size\n";
    
    # Находим поставщиков с наивысшим и наименьшим средним баллом
    my $current = $head;
    my ($best_supplier, $worst_supplier) = ($current, $current);
    my ($best_score, $worst_score) = ($current->get_average(), $current->get_average());
    
    while ($current) {
        my $avg = $current->get_average();
        if ($avg > $best_score) {
            $best_score = $avg;
            $best_supplier = $current;
        }
        if ($avg < $worst_score) {
            $worst_score = $avg;
            $worst_supplier = $current;
        }
        $current = $current->{next};
    }
    
    if ($size > 1) {
        printf "Лучший поставщик: %s (средний балл: %.2f)\n", $best_supplier->{name}, $best_score;
        printf "Худший поставщик: %s (средний балл: %.2f)\n", $worst_supplier->{name}, $worst_score;
    }
}

# Основной цикл программы
sub main_loop {
    print "=== Система управления поставщиками ===\n";
    
    while (1) {
        print "\n" . "=" x 50 . "\n";
        print "Выберите операцию:\n";
        print "1. Добавить поставщика\n";
        print "2. Удалить поставщика\n";
        print "3. Вывести список поставщиков\n";
        print "4. Сравнить поставщиков\n";
        print "5. Показать статистику\n";
        print "6. Выйти\n";
        print "Ваш выбор: ";
        
        chomp(my $choice = <>);
        
        # Проверяем корректность выбора
        unless (defined $choice && $choice =~ /^[1-6]$/) {
            print "Неверный выбор. Пожалуйста, введите число от 1 до 6.\n";
            next;
        }
        
        if ($choice == 1) {
            $head = add_supplier();
        } elsif ($choice == 2) {
            $head = delete_supplier();
        } elsif ($choice == 3) {
            print "\n--- Список поставщиков ---\n";
            $head ? $head->print_list() : print "Список поставщиков пуст.\n";
        } elsif ($choice == 4) {
            compare_suppliers();
        } elsif ($choice == 5) {
            show_statistics();
        } elsif ($choice == 6) {
            print "\nВыход из программы. До свидания!\n";
            last;
        }
    }
}

# Обработка сигналов 
$SIG{INT} = sub {
    print "\n\nПрограмма прервана пользователем. До свидания!\n";
    exit(0);
};

# Запуск основной программы
main_loop();

# Очистка памяти при выходе
END {
    if ($head) {
        print "\nОчистка памяти...\n";
    }
}