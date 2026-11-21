#!/usr/bin/env bash
# Лабораторная 14 (ORDER_BY_GROUP_BY.md): MySQL 8.0, очистка лога,
# эксперименты 1-7, экспорт лога и дамп базы sort_practice.
# Запуск: bash database/14-order-by-group-by/commands.sh
set -euo pipefail

LAB="14-order-by-group-by"
NAME="imfua-$LAB"
DB="sort_practice"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

export MYSQL_PASSWORD="${MYSQL_PASSWORD:-123}"       # по инструкции: 123
VOLUME="imfua_14_order_by_group_by_data"              # в оригинале: mysql_data

echo "==> 1. Удаляем старый контейнер и volume"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker volume rm "$VOLUME" >/dev/null 2>&1 || true
rm -f "database/$LAB/artifacts/general.log" \
      "database/$LAB/artifacts/my_actions.log" \
      "database/$LAB/artifacts/$DB-dump.sql" \
      "database/$LAB/artifacts/sort_dump.sql"

echo "==> 2. my.cnf: копия database/_shared/my.cnf"
cp database/_shared/my.cnf "database/$LAB/my.cnf"

echo "==> 3. docker run (ORDER_BY_GROUP_BY.md, 1.2)"
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "$VOLUME:/var/lib/mysql" \
  -v "$ROOT/database/$LAB/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0
docker ps --filter "name=$NAME"

echo "==> 4. Ждём готовности MySQL"
until docker exec "$NAME" mysqladmin ping -uroot -p"$MYSQL_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 1
done
docker exec "$NAME" mysql -uroot -p"$MYSQL_PASSWORD" \
  -e "SHOW VARIABLES LIKE 'general_log'; SHOW VARIABLES LIKE 'log_output';"

echo "==> 5. Очищаем general.log до начала работы"
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

echo "==> 8. Дамп базы $DB"
bash scripts/dump-db.sh "$LAB" "$DB"

echo
echo "Файлы: database/$LAB/artifacts/{general.log,my_actions.log,$DB-dump.sql}"
