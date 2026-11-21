#!/usr/bin/env bash
# Лабораторная 11 (Aliases.md): запуск MySQL 8.0, очистка general.log,
# пошаговое выполнение SQL, экспорт лога и дамп базы alias_db.
# Запуск: bash database/11-aliases/commands.sh
set -euo pipefail

LAB="11-aliases"
NAME="imfua-$LAB"
DB="alias_db"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

# По инструкции пароль root = 123; тот же пароль используют scripts/*.sh.
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-123}"
VOLUME="imfua_11_aliases_data"   # изолированный volume (в оригинале mysql_alias_data)

echo "==> 1. Удаляем старый контейнер и его volume (если есть)"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker volume rm "$VOLUME" >/dev/null 2>&1 || true
# ВНИМАНИЕ: не используем 'docker volume prune -a' — он удалит все неиспользуемые volume хоста.

echo "==> 2. my.cnf: копия database/_shared/my.cnf (UTF-8 без BOM, LF)"
cp database/_shared/my.cnf "database/$LAB/my.cnf"

echo "==> 3. docker run (как в Aliases.md, 0.2)"
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "$VOLUME:/var/lib/mysql" \
  -v "$ROOT/database/$LAB/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0
docker ps --filter "name=$NAME"

echo "==> 4. Ждём готовности сервера"
until docker exec "$NAME" mysqladmin ping -uroot -p"$MYSQL_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 1
done

echo "==> 5. Проверяем, что general_log включён"
docker exec "$NAME" mysql -uroot -p"$MYSQL_PASSWORD" \
  -e "SHOW VARIABLES LIKE 'general_log'; SHOW VARIABLES LIKE 'log_output';"

echo "==> 6. Очищаем general.log перед работой (от пользователя mysql)"
docker exec -u mysql "$NAME" sh -c ': > /var/lib/mysql/general.log'
docker exec "$NAME" ls -la /var/lib/mysql/general.log

echo "==> 7. Выполняем SQL строго по порядку"
run_sql() {
  echo "    -> $1"
  docker exec -i "$NAME" mysql --default-character-set=utf8mb4 \
    -uroot -p"$MYSQL_PASSWORD" < "database/$LAB/$1"
}
run_sql 01_schema.sql
run_sql 02_seed.sql
run_sql 03_queries.sql

echo
echo "Для интерактивного выполнения (как в инструкции — лог содержит именно ваши действия):"
echo "  docker exec -it $NAME mysql --default-character-set=utf8mb4 -uroot -p"
echo "  (пароль: $MYSQL_PASSWORD)"
echo "  \\q  — выход из клиента"

echo "==> 8. Лог: general.log -> my_actions.log (только действия пользователя)"
# Фильтрация в точности как в Aliases.md, раздел 10 (если нужна вручную):
# docker exec "$NAME" cat /var/lib/mysql/general.log \
#   | grep -E "Query[[:space:]]+(CREATE|INSERT|SELECT|UPDATE|DELETE|ALTER|DROP|RENAME|DESCRIBE|EXPLAIN|SHOW DATABASES|SHOW TABLES|SHOW FULL TABLES|SHOW CREATE|SHOW VARIABLES LIKE)" \
#   | grep -v -E "INSERT INTO help_|INSERT INTO time_zone|INSERT INTO mysql\.|SELECT \* FROM mysql\.general_log" \
#   > "database/$LAB/my_actions.log"
# docker cp "$NAME":/var/lib/mysql/general.log "database/$LAB/general.log"
bash scripts/export-log.sh "$LAB"

echo "==> 9. Дамп базы $DB"
bash scripts/dump-db.sh "$LAB" "$DB"

echo
echo "Готово. Смотри database/$LAB/README.md и database/$LAB/artifacts/"
echo "  artifacts/general.log       — полный general.log"
echo "  artifacts/my_actions.log    — отфильтрованные действия"
echo "  artifacts/$DB-dump.sql      — дамп (без GTID)"
