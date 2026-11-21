#!/usr/bin/env bash
# 20-file-server: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Подготовка каталога"
cat <<'CMD'
ls -la share/
# положите в share/ файлы, которые нужно раздать
CMD

step "2. Загрузка образа"
cat <<'CMD'
docker pull httpd:alpine
CMD

step "3. Запуск (Git-Bash/Linux/WSL/Mac)"
cat <<'CMD'
docker run -d \
  --name my-apache-server \
  -p 8084:80 \
  -v "$(pwd)/share":/usr/local/apache2/htdocs/ \
  httpd:alpine
CMD

step "4. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name my-apache-server `
  -p 8084:80 `
  -v "$(PWD):/usr/local/apache2/htdocs/" `
  httpd:alpine
CMD

step "5. Проверка работы"
cat <<'CMD'
curl -I http://localhost:8084/
# или открыть http://localhost:8084 в браузере
CMD

step "Очистка"
cat <<'CMD'
docker stop my-apache-server || true
docker rm -f my-apache-server || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
