#!/usr/bin/env bash
# Поднять локальный MariaDB из пользовательского tarball (без root и Docker).
# Используется только для реального выполнения SQL-лабораторных и сбора логов.
set -euo pipefail

BIN="${MARIADB_BIN:-/tmp/opencode/mariadb/bin}"
BASE="${MARIADB_BASE:-/tmp/opencode/mariadb}"
DATA="$BASE/data"
RUN="$BASE/run"
SOCKET="$BASE/run/mysqld.sock"
LOG="$DATA/general.log"

[ -x "$BIN/mariadbd" ] || { echo "Нет mariadbd в $BIN" >&2; exit 2; }
INSTALL_DB="$BIN/mariadb-install-db"
[ -x "$INSTALL_DB" ] || INSTALL_DB="$BASE/scripts/mariadb-install-db"
[ -x "$INSTALL_DB" ] || { echo "Нет mariadb-install-db в $BIN или $BASE/scripts" >&2; exit 2; }
mkdir -p "$DATA" "$RUN"

if [ ! -d "$DATA/mysql" ]; then
  echo "Инициализация datadir: $DATA"
  "$INSTALL_DB" \
    --datadir="$DATA" \
    --auth-root-authentication-method=normal \
    --skip-test-db >/dev/null
fi

: > "$LOG"

if [ -S "$SOCKET" ] && "$BIN/mariadb" --socket="$SOCKET" -uroot -e 'SELECT 1' >/dev/null 2>&1; then
  echo "Сервер уже запущен: $SOCKET"
  exit 0
fi

echo "Запуск mariadbd..."
nohup "$BIN/mariadbd" \
  --datadir="$DATA" \
  --socket="$SOCKET" \
  --pid-file="$RUN/mysqld.pid" \
  --log-error="$RUN/mysqld.error.log" \
  --port=0 --skip-networking \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci \
  --general-log=1 \
  --general-log-file="$LOG" \
  --log-output=FILE \
  --innodb-buffer-pool-size=64M \
  --skip-name-resolve \
  >/dev/null 2>&1 &

for _ in $(seq 1 60); do
  if [ -S "$SOCKET" ] && "$BIN/mariadb" --socket="$SOCKET" -uroot -e 'SELECT 1' >/dev/null 2>&1; then
    ver=$("$BIN/mariadb" --socket="$SOCKET" -uroot -N -B -e 'SELECT VERSION()')
    echo "MariaDB $ver готова, сокет $SOCKET"
    echo "general_log: $LOG"
    exit 0
  fi
  sleep 1
done

echo "Не удалось дождаться сервера. Лог: $RUN/mysqld.error.log" >&2
tail -n 30 "$RUN/mysqld.error.log" >&2 || true
exit 1
