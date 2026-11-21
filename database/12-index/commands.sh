#!/usr/bin/env bash
# Лабораторная 12 (Index.md): MySQL 8.0, очистка general.log, эксперименты 1-6,
# экспорт лога и дамп базы index_practice.
# Запуск: bash database/12-index/commands.sh
set -euo pipefail

LAB="12-index"
NAME="imfua-$LAB"
DB="index_practice"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

export MYSQL_PASSWORD="${MYSQL_PASSWORD:-123}"   # по инструкции: 123
VOLUME="imfua_12_index_data"                      # в оригинале: mysql_data

echo "==> 1. Удаляем старый контейнер и volume"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker volume rm "$VOLUME" >/dev/null 2>&1 || true
# НЕ используем 'docker volume prune -a' — это удалит все неиспользуемые volume хоста.
rm -f "database/$LAB/artifacts/general.log" \
      "database/$LAB/artifacts/my_actions.log" \
      "database/$LAB/artifacts/$DB-dump.sql" \
      "database/$LAB/artifacts/index_dump.sql" \
      "database/$LAB/artifacts/index_dump_clean.sql"

echo "==> 2. my.cnf: копия database/_shared/my.cnf"
cp database/_shared/my.cnf "database/$LAB/my.cnf"

echo "==> 3. docker run (Index.md, 1.2)"
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "$VOLUME:/var/lib/mysql" \
  -v "$ROOT/database/$LAB/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0
docker ps --filter "name=$NAME"

echo "==> 4. Ждём готовности и проверяем флаги логирования"
until docker exec "$NAME" mysqladmin ping -uroot -p"$MYSQL_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 1
done
docker exec "$NAME" mysql -uroot -p"$MYSQL_PASSWORD" \
  -e "SHOW VARIABLES LIKE 'general_log'; SHOW VARIABLES LIKE 'slow_query_log'; SHOW VARIABLES LIKE 'log_output';"
# Если general_log = OFF:
# docker exec "$NAME" mysql -uroot -p"$MYSQL_PASSWORD" -e "SET GLOBAL general_log = 'ON';"

echo "==> 5. Очищаем general.log до начала экспериментов"
docker exec -u mysql "$NAME" sh -c ': > /var/lib/mysql/general.log'

echo "==> 6. Выполняем SQL по порядку"
run_sql() {
  echo "    -> $1"
  docker exec -i "$NAME" mysql --default-character-set=utf8mb4 \
    -uroot -p"$MYSQL_PASSWORD" < "database/$LAB/$1"
}
run_sql 01_schema.sql
run_sql 02_seed.sql
run_sql 03_queries.sql

echo
echo "Интерактивно (как в инструкции):"
echo "  docker exec -it $NAME mysql --default-character-set=utf8mb4 -uroot -p"
echo "  (пароль: $MYSQL_PASSWORD; \\q — выход)"

echo "==> 7. general.log -> my_actions.log"
bash scripts/export-log.sh "$LAB"

echo "==> 8. Дамп базы $DB (все индексы экспериментов попадут в дамп)"
bash scripts/dump-db.sh "$LAB" "$DB"

echo
echo "Файлы: database/$LAB/artifacts/{general.log,my_actions.log,$DB-dump.sql}"
