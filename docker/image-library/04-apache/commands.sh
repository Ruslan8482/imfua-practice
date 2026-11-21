#!/usr/bin/env bash
# 04-apache: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull httpd
CMD

step "2. Создание и запуск контейнера"
cat <<'CMD'
docker run -d --name my-apache -p 8081:80 httpd
docker ps
CMD

step "3. Проверка работы"
cat <<'CMD'
curl http://localhost:8081/
# или открыть http://localhost:8081 в браузере
CMD

step "4. Вход в контейнер и установка редактора"
cat <<'CMD'
docker exec -it my-apache bash
apt update && apt install -y micro
CMD

step "5. Редактирование страницы"
cat <<'CMD'
micro /usr/local/apache2/htdocs/index.html
# для русского текста добавьте <meta charset="UTF-8">
# сохранение: Ctrl+S, выход: Ctrl+Q или F10
exit
CMD

step "6. Повторная проверка в браузере"
cat <<'CMD'
# обновить http://localhost:8081 (Ctrl+R / F5)
curl http://localhost:8081/
CMD

step "Очистка"
cat <<'CMD'
docker stop my-apache || true
docker rm -f my-apache || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
