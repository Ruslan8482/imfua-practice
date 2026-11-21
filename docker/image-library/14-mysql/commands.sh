#!/usr/bin/env bash
# 14-mysql: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull mysql:8
CMD

step "2. Запуск в Git-Bash/Linux/WSL/Mac"
cat <<'CMD'
docker run -d \
  --name my-mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  mysql:8
CMD

step "3. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name my-mysql `
  -p 3306:3306 `
  -e MYSQL_ROOT_PASSWORD=rootpassword `
  -e MYSQL_DATABASE=mydb `
  -e MYSQL_USER=user `
  -e MYSQL_PASSWORD=password `
  mysql:8
CMD

step "4. Подключение (пароль: rootpassword)"
cat <<'CMD'
docker exec -it my-mysql mysql -u root -p
CMD

step "5. Проверка работы"
cat <<'CMD'
SHOW DATABASES;
SELECT version();
EXIT;
CMD

step "6. Логи контейнера"
cat <<'CMD'
docker logs my-mysql
CMD

step "Очистка"
cat <<'CMD'
docker stop my-mysql || true
docker rm -f my-mysql || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
