# Лабораторная работа 7 — сокеты

## Состав
- `server_low.pl` / `client_low.pl` — низкоуровневые сокеты PF_INET/PF_UNIX, TCP/UDP.
- `server_io.pl` / `client_io.pl` — те же режимы на `IO::Socket`.
- `reverse_server.pl` / `reverse_client.pl` — двунаправленный TCP‑эхо с инверсией строки.
- `test_reverse.sh` — автоматический тест реверс‑сервера.
- `test_io_tcp.sh` — быстрая проверка TCP‑режима на `IO::Socket`.
- `test_all.sh` — прогоняет все 8 комбинаций (INET/UNIX × TCP/UDP, low-level и IO::Socket).

## Быстрый старт
```bash
cd LR7
./reverse_server.pl          # терминал 1
./reverse_client.pl          # терминал 2
```

## Меню для low-level и IO::Socket
В начале работы скрипты спрашивают номер режима:
1 — Internet TCP, 2 — Internet UDP, 3 — UNIX TCP, 4 — UNIX UDP.

Примеры:
- TCP INET: `./server_low.pl` (выбрать 1) и `./client_low.pl` (1)
- UDP UNIX: `./server_io.pl` (4) и `./client_io.pl` (4)

Завершение: отправьте `exit` в поток/датаграмму, затем Ctrl+C на сервере (для stream‑серверов процесс продолжает слушать новые подключения).

> Важно: серверы читают только из сокета. Если набрать `exit` прямо в терминале сервера, ничего не произойдёт. Отправьте `exit` из клиента или нажмите Ctrl+C.

### Особенности UNIX UDP
- Клиент `client_low.pl` сам создаёт временный сокет `/tmp/lr7_unix_dgram_client_<pid>.sock` и удаляет его на выходе.
- Если файл сокета уже существует или нет прав в `/tmp`, может понадобиться `sudo` или предварительный `rm /tmp/lr7_unix_dgram_client_*.sock`.

## Автотесты
Скрипты пишут логи в `/tmp` и сами убивают поднятый сервер.

```bash
./test_reverse.sh   # проверка reverse_server/reverse_client
./test_io_tcp.sh    # проверка server_io/client_io в режиме Internet TCP
./test_all.sh       # прогон всех режимов
```

Ожидаемый вывод тестов: PASS‑сообщения, лог клиента, а в `/tmp/lr7_*.log` — журнал сервера.

## Освобождение портов и сокетов
- TCP/UDP: узнать процесс — `lsof -i :5050` (или другой порт), завершить `kill <PID>`.
- UNIX‑сокеты: `rm /tmp/lr7_unix_stream.sock` или `rm /tmp/lr7_io_unix_stream.sock` и т.п.
- Если сервер завис: `ps -f | grep lr7` и `kill`/`kill -9` по PID.
- `test_all.sh` подбирает случайные порты (40000‑49999) через переменные окружения `LR7_INET_TCP_PORT/LR7_INET_UDP_PORT/LR7_IO_INET_TCP_PORT/LR7_IO_INET_UDP_PORT`, чтобы избежать `Address already in use`.

## Требования
- Perl 5, стандартные модули, для IO‑части: `IO::Socket::INET`, `IO::Socket::UNIX`.
- Порты по умолчанию: 5050/5051 (low), 5150/5151 (IO), 5250 (reverse).
