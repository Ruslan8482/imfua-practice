#!/usr/bin/env bash
# Лабораторная 16 (Normalization.md): аномалии -> 3NF.
# Дамп ДО нормализации и ПОСЛЕ, экспорт general.log -> my_actions.log.
# Запуск: bash database/16-normalization-common/commands.sh
set -euo pipefail

LAB="16-normalization-common"
NAME="imfua-$LAB"
DB="shop_norm"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

export MYSQL_PASSWORD="${MYSQL_PASSWORD:-123}"        # по инструкции: 123
VOLUME="imfua_16_normalization_common_data"            # в оригинале: mysql_data
ART="database/$LAB/artifacts"

echo "==> 1. Удаляем старый контейнер и volume"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker volume rm "$VOLUME" >/dev/null 2>&1 || true
rm -f "$ART/general.log" "$ART/my_actions.log" \
      "$ART/$DB-dump.sql" "$ART/$DB-before-dump.sql" "$ART/$DB-after-dump.sql" \
      "$ART/dump_bad.sql" "$ART/norm_dump.sql"

echo "==> 2. my.cnf: копия database/_shared/my.cnf"
cp database/_shared/my.cnf "database/$LAB/my.cnf"

echo "==> 3. docker run --name shop_norm (контейнер: $NAME)"
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

echo "==> 5. Очищаем general.log до начала работы"
docker exec -u mysql "$NAME" sh -c ': > /var/lib/mysql/general.log'
docker exec "$NAME" ls -la /var/lib/mysql/general.log

echo "==> 6. Плохая таблица и демонстрация аномалий"
run_sql() {
  echo "    -> $1"
  docker exec -i "$NAME" mysql --default-character-set=utf8mb4 \
    -uroot -p"$MYSQL_PASSWORD" < "database/$LAB/$1"
}
run_sql 01_schema.sql
run_sql 02_seed.sql
run_sql 03_queries.sql

echo "==> 7. Дамп ДО нормализации"
bash scripts/dump-db.sh "$LAB" "$DB"
cp "$ART/$DB-dump.sql" "$ART/$DB-before-dump.sql"

echo "==> 8. Схема 3NF, перенос данных и проверки"
run_sql 04_normalize.sql

echo "==> 9. Дамп ПОСЛЕ нормализации"
bash scripts/dump-db.sh "$LAB" "$DB"
cp "$ART/$DB-dump.sql" "$ART/$DB-after-dump.sql"

echo "==> 10. general.log -> my_actions.log (только действия пользователя)"
bash scripts/export-log.sh "$LAB"

echo
echo "Интерактивно (как в инструкции):"
echo "  docker exec -it $NAME mysql --default-character-set=utf8mb4 -uroot -p"
echo "  (пароль: $MYSQL_PASSWORD; \\q — выход)"

echo
echo "Готово:"
echo "  $ART/$DB-before-dump.sql  — orders_bad с дублированием и аномалиями"
echo "  $ART/$DB-after-dump.sql   — 4 таблицы 3NF + orders_bad_backup"
echo "  $ART/my_actions.log       — только ваши SQL-команды"
