#!/usr/bin/env bash
# 17-http-file-server: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Подготовка тестового файла в share/"
cat <<'CMD'
cd share
echo "Hello from HTTP server" > test.txt
cd ..
CMD

step "2. Загрузка образа"
cat <<'CMD'
docker pull nginx:alpine
CMD

step "3. Запуск (Git-Bash/Linux/WSL/Mac)"
cat <<'CMD'
docker run -d \
  --name http-server \
  -p 8082:80 \
  -v "$(pwd)/share":/usr/share/nginx/html \
  nginx:alpine
CMD

step "4. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name http-server `
  -p 8082:80 `
  -v ${PWD}/share:/usr/share/nginx/html `
  nginx:alpine
CMD

step "5. Проверка работы"
cat <<'CMD'
curl http://localhost:8082/test.txt
# или открыть http://localhost:8082/ в браузере
CMD

step "Очистка"
cat <<'CMD'
docker stop http-server || true
docker rm -f http-server || true
rm -f share/test.txt || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
