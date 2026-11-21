#!/usr/bin/env bash
# 12-python: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull python:alpine
CMD

step "2. Скрипт hello.py уже лежит в каталоге задания"
cat <<'CMD'
print('Hello from Python in Docker')
CMD

step "3. Запуск скрипта (Git-Bash/Linux/WSL/Mac)"
cat <<'CMD'
docker run --rm -v "$(pwd)":/app python:alpine python /app/hello.py
CMD

step "4. Вариант для PowerShell"
cat <<'CMD'
docker run --rm -v ${pwd}:/app python:alpine python /app/hello.py
CMD

step "5. Интерактивный Python (опционально)"
cat <<'CMD'
docker run -it --rm python:alpine python
# внутри REPL:
print('Hello from Docker')
exit()
CMD

step "Очистка"
cat <<'CMD'
docker stop python || true
docker rm -f python || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
