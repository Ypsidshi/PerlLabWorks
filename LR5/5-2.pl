#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';

# Обработка аргументов командной строки ДО ввода пользователя
my $output_option = shift @ARGV // 'screen';
my $output_file   = 'directory_tree.txt';
my $fh;

print "Введите корневой каталог: ";
chomp(my $root_dir = <STDIN>);  # Явно указываем STDIN
$root_dir = '.' if !defined($root_dir) || $root_dir eq '';

die "Каталог '$root_dir' не существует или не является директорией.\n" unless -d $root_dir;

# Открываем файл только после ввода каталога
if ($output_option eq 'file') {
    open($fh, '>', $output_file) or die "Не могу открыть '$output_file' для записи: $!";
    print "Результат будет сохранен в файл: $output_file\n";
} elsif ($output_option ne 'screen') {
    warn "Неизвестная опция вывода '$output_option'. Будет использован вывод на экран.\n";
    $output_option = 'screen';
}

sub emit {
    my ($text) = @_;
    if (defined $fh) {
        print $fh $text;
    } else {
        print $text;
    }
}

# Самостоятельная реализация обхода дерева каталогов
sub traverse_directory {
    my ($path, $indent, $visited) = @_;
    $visited = {} unless defined $visited;
    
    # Защита от циклических ссылок
    my $real_path = eval { abs_path($path) } || $path;
    if ($visited->{$real_path}++) {
        emit($indent . "[ЦИКЛИЧЕСКАЯ ССЫЛКА: $path]\n");
        return;
    }
    
    # Используем низкоуровневые операции для чтения каталога
    my $dir_handle;
    unless (opendir($dir_handle, $path)) {
        emit($indent . "[ОШИБКА: Не могу открыть каталог '$path']\n");
        return;
    }
    
    # Читаем и сортируем записи вручную
    my @entries;
    while (my $entry = readdir($dir_handle)) {
        next if $entry eq '.' or $entry eq '..';
        push @entries, $entry;
    }
    closedir($dir_handle);
    
    # Сортировка вручную
    @entries = sort @entries;
    
    # Обработка каждой записи
    foreach my $entry (@entries) {
        my $full_path = "$path/$entry";
        $full_path =~ s{//}{/}; # Убираем двойные слеши
        
        # Определяем тип записи
        if (-l $full_path) {
            my $target = readlink($full_path) || 'неизвестно';
            emit($indent . "Ссылка: $entry -> $target\n");
        }
        elsif (-d $full_path) {
            emit($indent . "Каталог: $entry/\n");
            traverse_directory($full_path, $indent . "    ", $visited);
        }
        elsif (-f $full_path) {
            my $size = -s $full_path;
            my $is_readable = (-r $full_path) ? 'Чтение: да' : 'Чтение: нет';
            my $is_writable = (-w $full_path) ? 'Запись: да' : 'Запись: нет';
            
            # Получаем время модификации файла
            my @stats = stat($full_path);
            if (@stats) {
                my $mtime = $stats[9];
                my ($sec, $min, $hour, $day, $month, $year) = localtime($mtime);
                $year += 1900;
                $month += 1;
                my $timestamp = sprintf("%02d-%02d-%04d %02d:%02d:%02d", $day, $month, $year, $hour, $min, $sec);
                
                emit($indent . "Файл: $entry (Размер: $size байт, $is_readable, $is_writable, Дата изменения: $timestamp)\n");
            } else {
                emit($indent . "Файл: $entry (Размер: $size байт, $is_readable, $is_writable, Дата: недоступно)\n");
            }
        }
        else {
            emit($indent . "Неизвестный тип: $entry\n");
        }
    }
    
    # Удаляем путь из посещенных при выходе из рекурсии
    delete $visited->{$real_path};
}

emit("Дерево каталога '$root_dir':\n");
traverse_directory($root_dir, '');

if (defined $fh) {
    close $fh;
    print "Результат сохранен в файл: $output_file\n";
}