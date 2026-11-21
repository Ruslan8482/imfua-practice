#!/usr/bin/env bash
# 10-redis: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull redis:alpine
CMD

step "2. Запуск контейнера"
cat <<'CMD'
docker run -d --name my-redis -p 6379:6379 redis:alpine
docker ps
CMD

step "3. Подключение к Redis CLI"
cat <<'CMD'
docker exec -it my-redis redis-cli
CMD

step "4. Проверка работы"
cat <<'CMD'
PING
SET lesson hello
GET lesson
EXIT
CMD

step "5. Просмотр логов"
cat <<'CMD'
docker logs my-redis
CMD

step "Очистка"
cat <<'CMD'
docker stop my-redis || true
docker rm -f my-redis || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
