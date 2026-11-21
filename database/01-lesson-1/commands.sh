#!/usr/bin/env bash
# Лабораторная 01 (Lesson_1.md) — команды для ручного запуска.
# В ЭТОЙ СРЕДЕ НЕ ВЫПОЛНЯЕТСЯ: Docker/MySQL здесь отсутствуют.
# Контейнер: imfua-01-lesson-1 (в оригинале инструкции — my-mysql).
# База: sales. Пароль root из инструкции — 123.
set -euo pipefail

LAB="01-lesson-1"
NAME="imfua-${LAB}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LABDIR="$ROOT/database/${LAB}"

# --- Оригинал инструкции (Git-Bash, для справки) -------------------
# docker run --name my-mysql \
#   -e MYSQL_ROOT_PASSWORD=123 \
#   -e LANG=C.UTF-8 \
#   -v mysql_data:/var/lib/mysql \
#   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
#   -d mysql:8.0

# --- Шаг 1. Поднять контейнер -------------------------------------
# Имя volume уточнено под лабораторную, чтобы не задевать другие задания.
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "imfua-01-lesson-1-data:/var/lib/mysql" \
  -v "$LABDIR/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0

docker ps

# --- Шаг 2. Очистить general.log перед работой --------------------
docker exec "$NAME" sh -c ': > /var/lib/mysql/general.log'

# --- Шаг 3. Подключение (вручную, пошагово) -----------------------
# docker exec -it "$NAME" mysql --default-character-set=utf8mb4 -uroot -p
# Внутри клиента: SHOW DATABASES; затем выполнить SQL-файлы по порядку.
# Для неинтерактивного прогона:
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/01_schema.sql"
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/02_seed.sql"
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/03_queries.sql"

# --- Шаг 4. Лог ----------------------------------------------------
# Оригинал: docker exec my-mysql cat /var/lib/mysql/general.log | grep "Query" ... > my_actions.log
docker cp "$NAME:/var/lib/mysql/general.log" "$LABDIR/artifacts/general.log"
# Из каталога database/: bash ../scripts/export-log.sh 01-lesson-1
bash "$ROOT/scripts/export-log.sh" "$LAB"

# --- Шаг 5. Дамп БД sales -----------------------------------------
# Оригинал:
# docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot \
#   --set-gtid-purged=OFF --single-transaction sales > dump_clean.sql
# Из каталога database/: bash ../scripts/dump-db.sh 01-lesson-1 sales
MYSQL_PASSWORD=123 bash "$ROOT/scripts/dump-db.sh" "$LAB" sales

echo "Готово: artifacts/my_actions.log и artifacts/sales-dump.sql"
