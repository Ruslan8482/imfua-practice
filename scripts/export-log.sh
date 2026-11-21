#!/usr/bin/env bash
# Выгрузить general.log и оставить только действия пользователя.
# Использование: bash scripts/export-log.sh 01-lesson-1
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

LAB="${1:?Укажите каталог лабораторной}"
NAME="imfua-$LAB"
LABDIR="database/$LAB"
mkdir -p "$LABDIR/artifacts" database/logs

docker cp "$NAME:/var/lib/mysql/general.log" "$LABDIR/artifacts/general.log"

grep -vE 'Connect|Quit|SET NAMES|SHOW VARIABLES|INSERT INTO (help_topic|time_zone)|SET timestamp|administrator command' \
  "$LABDIR/artifacts/general.log" > "$LABDIR/artifacts/my_actions.log" || true

cp "$LABDIR/artifacts/my_actions.log" "database/logs/${LAB}-actions.log"
echo "Лог выгружен: $LABDIR/artifacts/my_actions.log"
echo "Также скопирован: database/logs/${LAB}-actions.log"
