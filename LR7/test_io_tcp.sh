#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

SERVER_LOG=/tmp/lr7_io_tcp_server.log
CLIENT_LOG=/tmp/lr7_io_tcp_client.log
PORT=5150

cleanup() {
  [[ -n "${SERVER_PID:-}" && -e /proc/$SERVER_PID ]] && kill $SERVER_PID 2>/dev/null || true
}
trap cleanup EXIT

# Запускаем сервер в TCP INET (вариант 1)
{
  printf "1\n" | ./server_io.pl
} >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!
sleep 0.4

# Клиент: вариант 1, отправляем пару строк и exit
{
  printf "1\nhello\nworld\nexit\n"
} | ./client_io.pl >"$CLIENT_LOG" 2>&1

if grep -q "hello" "$SERVER_LOG" && grep -q "world" "$SERVER_LOG"; then
  echo "[PASS] IO::Socket TCP INET"
else
  echo "[FAIL] IO::Socket TCP INET (см. логи $CLIENT_LOG $SERVER_LOG)"
  exit 1
fi
