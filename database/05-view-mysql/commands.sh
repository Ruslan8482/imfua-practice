#!/usr/bin/env bash
# Лабораторная 05 (VIEW_MySQL.md) — команды для ручного запуска.
# В ЭТОЙ СРЕДЕ НЕ ВЫПОЛНЯЕТСЯ: Docker/MySQL здесь отсутствуют.
# Контейнер: imfua-05-view-mysql (в оригинале — my-mysql), БД: sql_practice.
set -euo pipefail

LAB="05-view-mysql"
NAME="imfua-${LAB}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LABDIR="$ROOT/database/${LAB}"

# --- Разделы 0-1. Оригинал инструкции -----------------------------
# docker restart my-mysql        # если контейнер уже создан
# docker run --name my-mysql \
#   -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
#   -e MYSQL_INITDB_SKIP_TZINFO=1 \
#   -v mysql_data:/var/lib/mysql \
#   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
#   -d mysql:8.0

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "imfua-05-view-mysql-data:/var/lib/mysql" \
  -v "$LABDIR/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0
docker ps

docker exec "$NAME" sh -c ': > /var/lib/mysql/general.log'
# docker exec -it "$NAME" mysql --default-character-set=utf8mb4 -uroot -p  # пароль 123
# При ERROR 2002 подождать 10-20 с и повторить подключение.

# --- Разделы 2-12: схема, данные, VIEW, CHECK OPTION, права --------
for step in 01_schema 02_seed 03_views 04_check_rights; do
  docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 \
    < "$LABDIR/${step}.sql"
done

# --- Раздел 13. Дамп ----------------------------------------------
# Оригинал: docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot sql_practice > dump.sql
# Из каталога database/: bash ../scripts/dump-db.sh 05-view-mysql sql_practice
MYSQL_PASSWORD=123 bash "$ROOT/scripts/dump-db.sh" "$LAB" sql_practice

# --- Раздел 14. Лог -----------------------------------------------
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/04_log.sql"

# Оригинал: docker cp my-mysql:/var/lib/mysql/general.log ./general.log
docker cp "$NAME:/var/lib/mysql/general.log" "$LABDIR/artifacts/general.log"
# Оригинал: docker exec my-mysql cat /var/lib/mysql/general.log | grep "Query" ... > my_actions.log
# Из каталога database/: bash ../scripts/export-log.sh 05-view-mysql
bash "$ROOT/scripts/export-log.sh" "$LAB"

echo "Готово: artifacts/my_actions.log и artifacts/sql_practice-dump.sql"
