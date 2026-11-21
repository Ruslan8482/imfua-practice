#!/usr/bin/env bash
# Лабораторная № 4 по нормализации: запуск MySQL, SQL, дампы и лог.
set -euo pipefail
cd "$(dirname "$0")"

LAB="09-normalization-4"
NAME="imfua-$LAB"
DB="orders_rep_norm"
PASS="root"

# 1. Контейнер MySQL 8 с общим конфигом логирования.
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="$PASS" \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v "imfua-${LAB}-data:/var/lib/mysql" \
  -v "$(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  mysql:8.0

# 2. Ждём готовности сервера.
for _ in $(seq 1 60); do
  if docker exec "$NAME" mysqladmin -uroot -p"$PASS" ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# 3. Чистый лог: попадут только наши действия.
docker exec "$NAME" sh -c ': > /var/lib/mysql/general.log'

# 4. Схема и демо-данные, затем дамп «до».
for f in 01_schema.sql 02_seed.sql; do
  docker exec -i -e MYSQL_PWD="$PASS" "$NAME" \
    mysql --default-character-set=utf8mb4 -uroot < "$f"
done

bash ../scripts/dump-db.sh "$LAB" "$DB"
mv "artifacts/${DB}-dump.sql" "artifacts/${DB}-before.sql"

# 5. Перенос, проверки, демонстрация аномалий, удаление старой таблицы.
docker exec -i -e MYSQL_PWD="$PASS" "$NAME" \
  mysql --default-character-set=utf8mb4 -uroot < 03_queries.sql

# 6. Итоговый дамп и отфильтрованный лог действий.
bash ../scripts/dump-db.sh "$LAB" "$DB"
bash ../scripts/export-log.sh "$LAB"

echo "Готово. Отчёт: README.md; артефакты: artifacts/; скриншоты: evidence/."
echo "Ручной ввод SQL (если нужен лог набранных команд):"
echo "  docker exec -it $NAME mysql --default-character-set=utf8mb4 -uroot -p$PASS"
