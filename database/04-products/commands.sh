#!/usr/bin/env bash
# Лабораторная 04 (Products.md) — команды для ручного запуска.
# В ЭТОЙ СРЕДЕ НЕ ВЫПОЛНЯЕТСЯ: Docker/MySQL здесь отсутствуют.
# Контейнер: imfua-04-products (в оригинале — products-mysql), БД: shop.
set -euo pipefail

LAB="04-products"
NAME="imfua-${LAB}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LABDIR="$ROOT/database/${LAB}"
DUMP="$LABDIR/artifacts/shop-dump.sql"

# --- Шаг 1. Оригинал инструкции -----------------------------------
# docker run --name products-mysql \
#   -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
#   -v mysql_data:/var/lib/mysql \
#   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
#   -d mysql:latest

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "imfua-04-products-data:/var/lib/mysql" \
  -v "$LABDIR/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:latest
docker ps

docker exec "$NAME" sh -c ': > /var/lib/mysql/general.log'
# docker exec -it "$NAME" mysql --default-character-set=utf8mb4 -uroot -p  # пароль 123

# --- Шаги 1-4: схема, данные, запросы ------------------------------
for step in 01_schema 02_seed 03_queries; do
  docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 \
    < "$LABDIR/${step}.sql"
done

# --- Лог (общий my.cnf включает general_log) ----------------------
docker cp "$NAME:/var/lib/mysql/general.log" "$LABDIR/artifacts/general.log"
# Из каталога database/: bash ../scripts/export-log.sh 04-products
bash "$ROOT/scripts/export-log.sh" "$LAB"

# --- Шаг 5. Дамп ---------------------------------------------------
# Оригинал:
# docker exec -e MYSQL_PWD=123 products-mysql mysqldump -uroot shop > dump.sql
# Из каталога database/: bash ../scripts/dump-db.sh 04-products shop
MYSQL_PASSWORD=123 bash "$ROOT/scripts/dump-db.sh" "$LAB" shop

# --- Шаг 6. Удаление БД -------------------------------------------
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/04_drop.sql"

# --- Шаг 7. Восстановление ----------------------------------------
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/04_restore.sql"

# Оригинал: docker exec -i products-mysql mysql -uroot -p123 --force shop < dump.sql
# --force предписан инструкцией; он игнорирует ошибки импорта.
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql -uroot --default-character-set=utf8mb4 --force shop < "$DUMP"

docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/04_verify.sql"

echo "Готово: artifacts/my_actions.log и artifacts/shop-dump.sql"
