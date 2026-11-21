#!/usr/bin/env bash
# Лабораторная 02 (Begin_MySQL_1.md) — команды для ручного запуска.
# В ЭТОЙ СРЕДЕ НЕ ВЫПОЛНЯЕТСЯ: Docker/MySQL здесь отсутствуют.
# Контейнер: imfua-02-begin-mysql-1 (в оригинале — my-mysql), БД: my_database.
set -euo pipefail

LAB="02-begin-mysql-1"
NAME="imfua-${LAB}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LABDIR="$ROOT/database/${LAB}"

# --- Шаг 1. Запуск контейнера -------------------------------------
# Оригинал:
# docker run --name my-mysql \
#   -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
#   -v mysql_data:/var/lib/mysql \
#   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
#   -d mysql:8.0

# Очистка только учебного контейнера (без docker prune!)
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "imfua-02-begin-mysql-1-data:/var/lib/mysql" \
  -v "$LABDIR/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0
docker ps
# Физические файлы БД внутри контейнера (не обязательно):
docker exec -it "$NAME" ls -la /var/lib/mysql

# --- Шаг 2. Подключение и шаги 3-6 --------------------------------
docker exec "$NAME" sh -c ': > /var/lib/mysql/general.log'
# docker exec -it "$NAME" mysql --default-character-set=utf8mb4 -uroot -p  # пароль 123
# Выйти из клиента: \q

docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/01_schema.sql"
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/02_seed.sql"
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/03_queries.sql"

# --- Шаг 7. Дамп БД ДО удаления данных ----------------------------
# Оригинал (Linux WSL):
# docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot \
#   --set-gtid-purged=OFF --single-transaction my_database > dump_clean.sql
# Из каталога database/: bash ../scripts/dump-db.sh 02-begin-mysql-1 my_database
MYSQL_PASSWORD=123 bash "$ROOT/scripts/dump-db.sh" "$LAB" my_database

# --- Шаги 8-10. Удаление записи, таблицы и БД ---------------------
# docker exec -it "$NAME" mysql --default-character-set=utf8mb4 -uroot -p  # затем USE my_database
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/04_cleanup.sql"

# --- Шаг 4 отчёта. Лог -------------------------------------------
# Оригинал:
# docker exec my-mysql cat /var/lib/mysql/general.log | grep "Query" \
#   | grep -v -E "SET NAMES|SET autocommit|SET sql_mode|SET character_set_results|SHOW VARIABLES|SHOW STATUS|SHOW WARNINGS|SELECT @@|SELECT DATABASE\(\)|time_zone" \
#   > my_actions.log
docker exec "$NAME" ls -la /var/lib/mysql/general.log
docker cp "$NAME:/var/lib/mysql/general.log" "$LABDIR/artifacts/general.log"
# Из каталога database/: bash ../scripts/export-log.sh 02-begin-mysql-1
bash "$ROOT/scripts/export-log.sh" "$LAB"

# --- Шаг 5. Управление контейнером (по необходимости) -------------
# docker stop "$NAME"
# docker start "$NAME"
# docker logs "$NAME" > "$LABDIR/artifacts/container.log"

echo "Готово: artifacts/my_actions.log и artifacts/my_database-dump.sql"
