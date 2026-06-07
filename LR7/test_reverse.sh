#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

SERVER_LOG=/tmp/lr7_reverse_server.log
CLIENT_LOG=/tmp/lr7_reverse_client.log
PORT=5250

cleanup() {
  [[ -n "${SERVER_PID:-}" && -e /proc/$SERVER_PID ]] && kill $SERVER_PID 2>/dev/null || true
}
trap cleanup EXIT

# Порт 5250 может быть недоступен в среде CI; пробуем случайный свободный.
PORT=${PORT:-$(shuf -i 40000-49999 -n 1)}
./reverse_server.pl "$PORT" >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!
sleep 0.4

expect_list=("hello" "Perl" "12345" "exit")
PASS=true
{
  for line in "${expect_list[@]}"; do
    printf "%s\n" "$line"
  done
} | ./reverse_client.pl "$PORT" >"$CLIENT_LOG" 2>&1 || PASS=false

if $PASS && grep -q "olleh" "$CLIENT_LOG" && grep -q "lreP" "$CLIENT_LOG"; then
  echo "[PASS] reverse_client/server"
else
  echo "[FAIL] reverse_client/server (см. логи $CLIENT_LOG $SERVER_LOG)"
  exit 1
fi
