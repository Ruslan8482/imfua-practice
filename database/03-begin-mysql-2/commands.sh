#!/usr/bin/env bash
# Лабораторная 03 (Begin_MySQL_2.md), шаги 1-14 — команды для ручного запуска.
# В ЭТОЙ СРЕДЕ НЕ ВЫПОЛНЯЕТСЯ: Docker/MySQL здесь отсутствуют.
# Контейнер: imfua-03-begin-mysql-2 (в оригинале — my-mysql), БД: sql_practice.
set -euo pipefail

LAB="03-begin-mysql-2"
NAME="imfua-${LAB}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LABDIR="$ROOT/database/${LAB}"
DUMP="$LABDIR/artifacts/sql_practice-dump.sql"

# --- Подготовка: оригинал инструкции -------------------------------
# my.cnf в оригинале: log_output = TABLE. Общий my.cnf репозитория пишет в FILE,
# поэтому шаг 1.1 в 01_setup.sql переключает лог в TABLE (позже — в TABLE,FILE).
# docker restart my-mysql                    # если контейнер уже был
# docker volume prune -a                     # осторожно: все неиспользуемые тома
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
  -v "imfua-03-begin-mysql-2-data:/var/lib/mysql" \
  -v "$LABDIR/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  -d mysql:8.0
docker ps

# --- Шаг 1-2: подключение (вручную) --------------------------------
docker exec "$NAME" sh -c ': > /var/lib/mysql/general.log'
# docker exec -it "$NAME" mysql --default-character-set=utf8mb4 -uroot -p  # пароль 123
# Если сразу ошибка ERROR 2002 — контейнер ещё инициализируется, подождите 10-20 с.

# --- Шаги 1-11: SQL по порядку -------------------------------------
for step in 01_setup 02_schema 03_seed 04_select 05_aggregates_joins \
            06_subqueries_union 07_modify 08_log_dump; do
  docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 \
    < "$LABDIR/${step}.sql"
done

# Файлы таблиц InnoDB внутри контейнера (не обязательно):
docker exec "$NAME" ls -la /var/lib/mysql/sql_practice

# --- Шаг 12.2: экспорт лога через VIEW (оригинал) ------------------
# docker exec -e MYSQL_PWD=123 my-mysql mysql -uroot \
#   --default-character-set=utf8mb4 \
#   -e "SELECT * FROM sql_practice.my_actions ORDER BY event_time DESC" \
#   > my_actions_export.log
docker exec -e MYSQL_PWD=123 "$NAME" mysql -uroot \
  --default-character-set=utf8mb4 \
  -e "SELECT * FROM sql_practice.my_actions ORDER BY event_time DESC" \
  > "$LABDIR/artifacts/my_actions_export.log"

# --- Шаг 12.3: дамп ------------------------------------------------
# Оригинал:
# docker exec my-mysql mysqldump -uroot -p123 sql_practice > dump.sql
# docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot \
#   --set-gtid-purged=OFF --single-transaction sql_practice > dump_clean.sql
# Из каталога database/: bash ../scripts/dump-db.sh 03-begin-mysql-2 sql_practice
MYSQL_PASSWORD=123 bash "$ROOT/scripts/dump-db.sh" "$LAB" sql_practice

# --- Шаг 13: удаление таблиц и БД ----------------------------------
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/09_drop.sql"

# --- Шаг 14: восстановление ----------------------------------------
# 14.1-14.2: проверить контейнер и дамп
docker ps -a
ls -lh "$DUMP"
head -n 30 "$DUMP"

# 14.3: пустая БД
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/10_restore.sql"

# 14.4: импорт дампа на хосте (без --force!)
# Оригинал: docker exec -i my-mysql mysql -uroot -p123 sql_practice < dump_clean.sql
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql -uroot --default-character-set=utf8mb4 sql_practice < "$DUMP"

# 14.5: проверка
docker exec -i -e MYSQL_PWD=123 "$NAME" mysql --default-character-set=utf8mb4 < "$LABDIR/11_verify.sql"

# --- Лог general.log (для scripts/export-log.sh включён режим TABLE,FILE) ---
docker cp "$NAME:/var/lib/mysql/general.log" "$LABDIR/artifacts/general.log"
# Из каталога database/: bash ../scripts/export-log.sh 03-begin-mysql-2
bash "$ROOT/scripts/export-log.sh" "$LAB"

echo "Готово: artifacts/my_actions*.log, artifacts/sql_practice-dump.sql"
