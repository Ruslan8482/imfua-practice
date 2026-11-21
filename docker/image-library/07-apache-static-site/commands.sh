#!/usr/bin/env bash
# 07-apache-static-site: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Подготовка каталога сайта"
cat <<'CMD'
# каталог site/ и файл site/index.html уже созданы в этом задании
cd site
ls -la
# при необходимости: echo '<h1>Hello Docker!</h1>' > index.html
CMD

step "2. Проверка порта и запуск с монтированием (Git-Bash/Linux/WSL/Mac)"
cat <<'CMD'
netstat -tuln | grep :8081 || true
docker pull httpd:alpine
docker run -d \
  --name my-apache-site \
  -p 8081:80 \
  -v "$(pwd)":/usr/local/apache2/htdocs \
  httpd:alpine
CMD

step "3. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name my-apache-site `
  -p 8081:80 `
  -v ${PWD}:/usr/local/apache2/htdocs `
  httpd:alpine
CMD

step "4. Проверка работы"
cat <<'CMD'
curl http://localhost:8081/
# или открыть http://localhost:8081 в браузере (Ctrl+R / Ctrl+Shift+R при кэше)
CMD

step "5. Изменение содержимого"
cat <<'CMD'
Отредактируйте site/index.html в VS Code на хосте и обновите страницу в браузере.
CMD

step "Очистка"
cat <<'CMD'
docker stop my-apache-site || true
docker rm -f my-apache-site || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
