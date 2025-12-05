#!/usr/bin/perl

use strict;
use warnings;

# Копирует файл и удаляет оригинал
sub copy_and_remove_file {
    my ($src, $dst) = @_;

    # Открываем исходный файл для чтения в бинарном режиме
    open(my $src_fh, '<:raw', $src)
        or die "Не могу открыть файл '$src' для чтения: $!";

    # Открываем целевой файл для записи в бинарном режиме
    open(my $dst_fh, '>:raw', $dst)
        or die "Не могу открыть файл '$dst' для записи: $!";

    my $buffer;
    while (read($src_fh, $buffer, 4096)) {
        print $dst_fh $buffer;
    }

    close $src_fh;
    close $dst_fh;

    # Удаляем исходный файл
    unlink($src) or warn "Не могу удалить файл '$src': $!";
}

# Рекурсивно перемещает содержимое каталога src в каталог dst
sub move_dir_recursive {
    my ($src, $dst) = @_;

    # Создаём целевой каталог, если его ещё нет
    unless (-d $dst) {
        mkdir($dst) or die "Не удалось создать каталог '$dst': $!";
    }

    opendir(my $dh, $src) or die "Не удалось открыть директорию '$src': $!";
    my @entries = readdir($dh);
    closedir($dh);

    foreach my $entry (@entries) {
        next if $entry eq '.' or $entry eq '..';

        my $src_path = "$src/$entry";
        my $dst_path = "$dst/$entry";

        if (-d $src_path) {
            # Рекурсивно переносим подкаталог
            move_dir_recursive($src_path, $dst_path);
        } elsif (-f $src_path) {
            # Перенос файла
            print "Перемещаем файл: $src_path -> $dst_path\n";
            copy_and_remove_file($src_path, $dst_path);
        } else {
            # Другие типы (ссылки, устройства и т.п.) можно пропустить или обработать отдельно
            warn "Пропускаю объект '$src_path' (не файл и не каталог)\n";
        }
    }

    # После переноса содержимого пытаемся удалить пустой каталог
    rmdir($src) or warn "Не удалось удалить каталог '$src': $!";
}

# Нормализация пути: убираем лишние слэши в конце
sub normalize_path {
    my ($path) = @_;
    $path =~ s{//+}{/}g;   # заменяем // на /
    $path =~ s{/$}{};      # убираем завершающий /
    return $path;
}

# --- Основная программа ---

# Запрашиваем у пользователя исходный каталог
print "Введите исходный каталог: ";
my $src_dir = <STDIN>;
chomp $src_dir;

# Запрашиваем у пользователя каталог-назначение (куда переместить исходный каталог)
print "Введите каталог назначения (куда переместить исходный каталог): ";
my $dest_parent = <STDIN>;
chomp $dest_parent;

# Нормализуем пути (упрощённо, без abs_path)
$src_dir     = normalize_path($src_dir);
$dest_parent = normalize_path($dest_parent);

# Проверяем, что исходный каталог существует и это директория
-d $src_dir or die "Исходный каталог '$src_dir' не существует или не является директорией.\n";

# Если каталог назначения не существует — пытаемся его создать
unless (-d $dest_parent) {
    mkdir($dest_parent) or die "Не удалось создать каталог назначения '$dest_parent': $!";
}

# Имя переносимого каталога (последний компонент пути)
my $src_name = $src_dir;
$src_name =~ s{.*/}{};

# Итоговый путь, куда будет перенесён каталог (как подкаталог назначения)
my $dest_dir = normalize_path("$dest_parent/$src_name");

# Защита: не позволяем перемещать каталог в самого себя или внутрь себя
my $norm_src  = normalize_path($src_dir);
my $norm_dest = normalize_path($dest_dir);

if ($norm_src eq $norm_dest) {
    die "Исходный и целевой каталоги совпадают. Перемещение невозможно.\n";
}

# Простая проверка: не позволяем перемещать каталог внутрь самого себя
my $src_with_slash  = "$norm_src/";
my $dest_with_slash = "$norm_dest/";

if (index($dest_with_slash, $src_with_slash) == 0) {
    die "Целевой каталог не может находиться внутри исходного.\n";
}

print "Перемещаем каталог '$src_dir' в '$dest_dir'...\n";

# Само перемещение (рекурсивно)
move_dir_recursive($src_dir, $dest_dir);

print "Перемещение завершено.\n";
