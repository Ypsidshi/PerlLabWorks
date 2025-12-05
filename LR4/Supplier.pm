# Модуль Supplier.pm
# Поля поставщика:
# - id: уникальный идентификационный номер поставщика (число).
# - name: название поставщика или компании.
# - category: категория поставщика.
# - speciality: специализация поставщика.
# - founding_year: год основания поставщика.
# - scores: массив оценок производительности (используется для расчета среднего балла).
# - next: ссылка на следующий элемент в связанном списке.

package Supplier;

use strict;
use warnings;
use Carp qw(croak carp);

# Создает новый объект класса Supplier с заданными параметрами.
# Параметры:
# - $class: имя класса
# - $id: идентификационный номер поставщика.
# - $name: название поставщика.
# - $category: категория поставщика.
# - $speciality: специализация.
# - $founding_year: год основания.
# - @scores: массив оценок производительности.
sub new {
    my ($class, $id, $name, $category, $speciality, $founding_year, @scores) = @_;
    
    # Валидация входных параметров
    _validate_parameters($id, $name, $category, $speciality, $founding_year, \@scores);
    
    my $self = {
        id            => $id,             # Уникальный ID поставщика
        name          => $name,           # Название поставщика
        category      => $category,       # Категория поставщика
        speciality    => $speciality,     # Специализация
        founding_year => $founding_year,  # Год основания
        scores        => [@scores],       # Копируем массив оценок производительности
        next          => undef            # Ссылка на следующий поставщик в списке
    };
    bless $self, $class;  #хэш как объект класса
    return $self;
}

# Вспомогательная функция для валидации параметров
sub _validate_parameters {
    my ($id, $name, $category, $speciality, $founding_year, $scores_ref) = @_;
    
    croak "ID поставщика обязателен и должен быть положительным числом" 
        unless defined $id && $id =~ /^\d+$/ && $id > 0;
    
    croak "Название поставщика обязательно" 
        unless defined $name && $name =~ /\S/;
    
    croak "Категория поставщика обязательна" 
        unless defined $category && $category =~ /\S/;
    
    croak "Специализация поставщика обязательна" 
        unless defined $speciality && $speciality =~ /\S/;
    
    croak "Год основания должен быть положительным числом" 
        unless defined $founding_year && $founding_year =~ /^\d+$/ && $founding_year > 0;
    
    croak "Оценки должны быть переданы как массив"
        unless ref $scores_ref eq 'ARRAY';
    
    # Проверяем, что все оценки - числа
    foreach my $score (@$scores_ref) {
        croak "Оценка '$score' должна быть числом" 
            unless !defined $score || $score =~ /^-?\d*\.?\d+$/;
    }
    
    return 1;
}

# Деструктор DESTROY
# Параметры:
# - $self: объект поставщика.
sub DESTROY {
    my $self = shift;
    # Убираем вывод в деструкторе, так как это может мешать при нормальной работе
    # print "Поставщик с номером $self->{id} удален.\n";  # Сообщение об удалении
}

# Метод get_average
# Вычисляет средний балл производительности на основе массива оценок.
# Если оценок нет, возвращает 0.
# Параметры:
# - $self: объект поставщика.
# Возвращает: средний балл (число с плавающей точкой).
sub get_average {
    my ($self) = @_;
    my $scores = $self->{scores};  # Получаем ссылку на массив оценок
    return 0 unless @$scores;      # Если массив пуст, средний = 0
    
    my $sum = 0;                   # Инициализируем сумму
    my $count = 0;
    
    foreach my $score (@$scores) {
        # Пропускаем неопределенные значения
        next unless defined $score;
        $sum += $score;
        $count++;
    }
    
    return $count > 0 ? $sum / $count : 0;  # Возвращаем среднее значение
}

# Метод compare
# Сравнивает двух поставщиков по году основания (кто старше/младше).
# Выводит сообщение о том, кто был основан раньше или если годы совпадают.
# Параметры:
# - $supplier1: первый объект поставщика.
# - $supplier2: второй объект поставщика.
# Возвращает: строку с результатом сравнения.
sub compare {
    my ($supplier1, $supplier2) = @_;
    
    croak "Оба параметра должны быть объектами Supplier"
        unless ref $supplier1 && ref $supplier1 eq 'Supplier' &&
               ref $supplier2 && ref $supplier2 eq 'Supplier';
    
    my $year1 = $supplier1->{founding_year};
    my $year2 = $supplier2->{founding_year};

    if ($year1 < $year2) {
        return "$supplier1->{name} (основан в $year1) старше, чем $supplier2->{name} (основан в $year2).\n";
    } elsif ($year1 > $year2) {
        return "$supplier2->{name} (основан в $year2) старше, чем $supplier1->{name} (основан в $year1).\n";
    } else {
        return "$supplier1->{name} и $supplier2->{name} основаны в один год ($year1).\n";
    }
}

# Метод append
# Добавляет нового поставщика в связанный список, сохраняя сортировку по ID (по возрастанию).
# Параметры:
# - $self: текущий списка (или undef для пустого списка).
# - $new_node: новый объект поставщика для добавления.
# Возвращает: новую голову списка после добавления.
sub append {
    my ($self, $new_node) = @_;
    
    # Валидация входных параметров
    croak "Новый узел должен быть объектом Supplier"
        unless ref $new_node && ref $new_node eq 'Supplier';
    
    # Проверка на дубликаты во всем списке
    if (_has_duplicate($self, $new_node->{id})) {
        carp "Дубликат узла с id $new_node->{id} не добавлен";
        return $self;
    }

    # Если список пуст или новый ID меньше/равен текущему
    if (!$self || $new_node->{id} < $self->{id}) {
        $new_node->{next} = $self;  # Вставляем новый узел перед текущим
        return $new_node;           # Новая голова - новый узел
    }
    
    # Если новый ID равен текущему (должно быть отловлено выше, но для надежности)
    if ($new_node->{id} == $self->{id}) {
        carp "Дубликат узла с id $new_node->{id} не добавлен";
        return $self;
    }

    # Итеративный подход вместо рекурсивного для избежания переполнения стека
    my $current = $self;
    while ($current->{next} && $current->{next}->{id} < $new_node->{id}) {
        $current = $current->{next};
    }
    
    # Проверяем следующий узел на дубликат
    if ($current->{next} && $current->{next}->{id} == $new_node->{id}) {
        carp "Дубликат узла с id $new_node->{id} не добавлен";
        return $self;
    }
    
    # Вставляем новый узел
    $new_node->{next} = $current->{next};
    $current->{next} = $new_node;
    
    return $self;  # Возвращаем исходную голову
}

# Вспомогательная функция для проверки дубликатов
sub _has_duplicate {
    my ($head, $id) = @_;
    my $current = $head;
    
    while ($current) {
        return 1 if $current->{id} == $id;
        $current = $current->{next};
    }
    
    return 0;
}

# Метод my_delete
# Удаляет поставщика с заданным ID из списка.
# Параметры:
# - $self: текущий узел списка.
# - $value: ID поставщика для удаления.
# Возвращает: новую голову списка после удаления
sub my_delete {
    my ($self, $value) = @_;
    
    croak "ID для удаления должен быть положительным числом"
        unless defined $value && $value =~ /^\d+$/ && $value > 0;
    
    if (!$self) {
        return undef;  # Если список пуст, ничего не делаем
    }
    
    # Если удаляем голову списка
    if ($self->{id} == $value) {
        my $next = $self->{next};  # Сохраняем следующий узел
        # Очищаем ссылки для помощи сборщику мусора
        $self->{next} = undef;
        return $next;              # Возвращаем следующий как новую голову
    }
    
    # Итеративный поиск узла для удаления
    my $current = $self;
    while ($current->{next}) {
        if ($current->{next}->{id} == $value) {
            my $node_to_delete = $current->{next};
            $current->{next} = $node_to_delete->{next};
            # Очищаем ссылки
            $node_to_delete->{next} = undef;
            last;
        }
        $current = $current->{next};
    }
    
    return $self;  # Возвращаем текущую голову
}

# Метод find_supplier
# Ищет поставщика в списке по ID.
# Проходит по связанному списку линейно.
# Параметры:
# - $self: голова списка.
# - $id: ID для поиска.
# Возвращает: объект поставщика, если найден, иначе undef.
sub find_supplier {
    my ($self, $id) = @_;
    
    croak "ID для поиска должен быть положительным числом"
        unless defined $id && $id =~ /^\d+$/ && $id > 0;
    
    my $current = $self;  # Начинаем с головы
    while ($current) {
        return $current if $current->{id} == $id;  # Нашли - возвращаем
        $current = $current->{next};              # Переходим к следующему
    }
    return undef;  # Не нашли
}

# Метод print_list
# Выводит список всех поставщиков в связанном списке.
# Параметры:
# - $self: голова списка.
sub print_list {
    my ($self) = @_;
    
    unless ($self) {
        print "Список поставщиков пуст.\n";
        return;
    }
    
    my $current = $self;  # Начинаем с головы
    my $count = 0;
    
    while ($current) {
        $count++;
        my $avg = $current->get_average;
        printf "%-3d. ID: %-4d Название: %-20s Категория: %-15s Специализация: %-15s Год: %-6d Средний балл: %.2f\n",
               $count, $current->{id}, $current->{name}, $current->{category}, 
               $current->{speciality}, $current->{founding_year}, $avg;
        $current = $current->{next};  # Переходим к следующему
    }
    print "Всего поставщиков: $count\n";
}

# Метод для получения размера списка
sub size {
    my ($self) = @_;
    my $count = 0;
    my $current = $self;
    
    while ($current) {
        $count++;
        $current = $current->{next};
    }
    
    return $count;
}

# Метод для проверки пустоты списка
sub is_empty {
    my ($self) = @_;
    return !defined $self;
}

1;  # Конец модуля
