# Erlang exercises

## 1. Среда
- установи Erlang: `sudo apt install erlang` (установлено в проекте);
- запуск интерпретатора: `erl`;
  - введите целое, дробное, атом, кортеж, список (пример: `123`, `3.14`, `atom`, `{a,1}`, `[1,2,3]`);
  - завершение: `halt().`.

## 2. Пример из книги [1]
- компиляция: `erlc echo.erl`;
- запуск: `erl -noshell -s echo go -s init stop`.

## 3. Пример из книги [2] и Fibonacci
- `factorial.escript` (как в книге):
  - `chmod +x factorial.escript`;
  - `./factorial.escript 5`.
- `fibonacci.escript` (аналогично):
  - `chmod +x fibonacci.escript`;
  - `./fibonacci.escript 8`.

Все файлы находятся в каталоге `Erlang/`.
