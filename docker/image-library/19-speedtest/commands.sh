#!/usr/bin/env bash
# 19-speedtest: команды задания (pull -> run -> проверка -> cleanup).
# ВНИМАНИЕ: это dry-run. Скрипт только печатает команды и НЕ запускает Docker.
# Для реального выполнения скопируйте нужные строки в терминал на машине с Docker.
# В текущей среде Docker отсутствует.
set -euo pipefail

step() { printf '\n== %s ==\n' "$1"; }

step "0. Проверка Docker и чистого листа"
cat <<'CMD'
docker version
docker ps -a
CMD

step "1. Загрузка образа"
cat <<'CMD'
docker pull adolfintel/speedtest
CMD

step "2. Запуск контейнера"
cat <<'CMD'
docker run -d -p 158:80 --name speedtest-server adolfintel/speedtest
CMD

step "3. Проверка работы"
cat <<'CMD'
docker ps
curl -I http://localhost:158/
# или открыть http://localhost:158/ в браузере и нажать GO
CMD

step "Очистка"
cat <<'CMD'
docker stop speedtest-server || true
docker rm -f speedtest-server || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
