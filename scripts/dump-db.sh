#!/usr/bin/env bash
# Сделать консистентный дамп без GTID.
# Использование: bash scripts/dump-db.sh 01-lesson-1 my_database
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

LAB="${1:?Укажите каталог лабораторной}"
DB="${2:?Укажите имя базы}"
NAME="imfua-$LAB"
LABDIR="database/$LAB"
mkdir -p "$LABDIR/artifacts" database/dumps

OUT="$LABDIR/artifacts/${DB}-dump.sql"
docker exec "$NAME" mysqldump -uroot -p"${MYSQL_PASSWORD:-root}" \
  --set-gtid-purged=OFF --single-transaction --routines --triggers \
  "$DB" > "$OUT"
cp "$OUT" "database/dumps/${LAB}-${DB}-dump.sql"
echo "Дамп создан: $OUT"
