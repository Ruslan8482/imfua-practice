#!/usr/bin/env bash
# Поднять изолированный MySQL для лабораторной.
# Использование: bash scripts/run-lab.sh 01-lesson-1
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

LAB="${1:-}"
if [ -z "$LAB" ] || [ ! -d "database/$LAB" ]; then
  echo "Использование: $0 <каталог-лабораторной>"
  echo "Доступные лабораторные:"
  find database -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9]-*' -printf '  %f\n' | sort
  exit 1
fi

LABDIR="database/$LAB"
cp database/_shared/my.cnf "$LABDIR/my.cnf"

NAME="imfua-$LAB"
PORT="${MYSQL_PORT:-3306}"
docker rm -f "$NAME" >/dev/null 2>&1 || true

docker run -d --name "$NAME" \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_PASSWORD:-root}" \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -p "${PORT}:3306" \
  -v "$(pwd)/$LABDIR/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  mysql:8.0

echo "Контейнер $NAME запущен (порт $PORT)."
echo "Очистите лог перед работой:"
echo "  docker exec $NAME sh -c ': > /var/lib/mysql/general.log'"
echo "Войдите в MySQL:"
echo "  docker exec -it $NAME mysql -uroot -p${MYSQL_PASSWORD:-root}"
echo "Выполните SQL из $LABDIR (01_*.sql, 02_*.sql, 03_*.sql)."
