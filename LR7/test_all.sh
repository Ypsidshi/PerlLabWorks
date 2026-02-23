#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

LOGDIR=/tmp/lr7_batch
mkdir -p "$LOGDIR"

tests=(
  "low 1 inet-tcp"
  "low 2 inet-udp"
  "low 3 unix-tcp"
  "low 4 unix-udp"
  "io  1 inet-tcp-io"
  "io  2 inet-udp-io"
  "io  3 unix-tcp-io"
  "io  4 unix-udp-io"
)

cleanup_sockets() {
  rm -f /tmp/lr7_unix_stream.sock /tmp/lr7_unix_dgram.sock
  rm -f /tmp/lr7_io_unix_stream.sock /tmp/lr7_io_unix_dgram.sock
  rm -f /tmp/lr7_unix_dgram_client_*.sock
}

run_test() {
  local suite=$1 mode=$2 name=$3
  local server client
  # динамический подбор портов, чтобы избежать EADDRINUSE
  local tcp_port udp_port
  tcp_port=$(shuf -i 40000-49999 -n 1)
  udp_port=$((tcp_port+1))

  if [[ $suite == "low" ]]; then
    server=./server_low.pl
    client=./client_low.pl
    export LR7_INET_TCP_PORT=$tcp_port
    export LR7_INET_UDP_PORT=$udp_port
  else
    server=./server_io.pl
    client=./client_io.pl
    export LR7_IO_INET_TCP_PORT=$tcp_port
    export LR7_IO_INET_UDP_PORT=$udp_port
  fi

  cleanup_sockets
  local slog="$LOGDIR/${name}_server.log"
  local clog="$LOGDIR/${name}_client.log"

  # старт сервера с выбранным режимом
  (printf "%s\n" "$mode" | "$server") >"$slog" 2>&1 &
  local spid=$!
  sleep 0.3

  # клиент отправляет две строки и exit
  {
    printf "%s\n" "$mode"
    printf "hello_%s\nworld_%s\nexit\n" "$name" "$name"
  } | "$client" >"$clog" 2>&1

  # Для stream сервер остаётся слушать — убиваем его после теста.
  if [[ $mode == 1 || $mode == 3 ]]; then
    kill "$spid" 2>/dev/null || true
  else
    # UDP/UNIX DGRAM должны завершиться после exit; если нет — добиваем.
    if kill -0 "$spid" 2>/dev/null; then
      kill "$spid" 2>/dev/null || true
    fi
  fi

  echo "[OK] $name (логи: $slog $clog)"
}

echo "Запуск сквозных тестов (логи в $LOGDIR)"
for t in "${tests[@]}"; do
  run_test $t
done

cleanup_sockets
echo "Готово."
