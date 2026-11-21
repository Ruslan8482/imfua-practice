#!/usr/bin/env bash
# 05-adminer: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull adminer:latest
CMD

step "2. Запуск в Git-Bash/Linux/WSL/Mac"
cat <<'CMD'
docker run -d \
  --name adminer \
  -p 8084:8080 \
  adminer:latest
CMD

step "3. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name adminer `
  -p 8084:8080 `
  adminer:latest
CMD

step "4. Проверка работы"
cat <<'CMD'
docker ps
curl http://localhost:8084/
# или открыть http://localhost:8084 в браузере
CMD

step "5. Второй экземпляр из того же образа"
cat <<'CMD'
docker run -d \
  --name adminer_2 \
  -p 8085:8080 \
  adminer:latest
# http://localhost:8085
CMD

step "6. Пример параметров подключения к PostgreSQL (если БД запущена)"
cat <<'CMD'
Система: PostgreSQL
сервер: host.docker.internal
логин: postgres
пароль: mysecretpassword
CMD

step "Очистка"
cat <<'CMD'
docker stop adminer adminer_2 || true
docker rm -f adminer adminer_2 || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
