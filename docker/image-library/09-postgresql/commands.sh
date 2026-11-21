#!/usr/bin/env bash
# 09-postgresql: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull postgres:alpine
CMD

step "2. Запуск в Git-Bash/Linux/WSL/Mac"
cat <<'CMD'
docker run -d \
  --name my-postgres \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=mysecretpassword \
  postgres:alpine
CMD

step "3. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name my-postgres `
  -p 5432:5432 `
  -e POSTGRES_PASSWORD=mysecretpassword `
  postgres:alpine
CMD

step "4. Проверка работы: подключение через psql"
cat <<'CMD'
docker exec -it my-postgres psql -U postgres
CMD

step "5. Демонстрационные SQL-команды"
cat <<'CMD'
\l
SELECT version();
\q
CMD

step "6. Просмотр логов"
cat <<'CMD'
docker logs my-postgres
CMD

step "Очистка"
cat <<'CMD'
docker stop my-postgres || true
docker rm -f my-postgres || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
