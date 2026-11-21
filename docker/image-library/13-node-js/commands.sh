#!/usr/bin/env bash
# 13-node-js: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull node:alpine
CMD

step "2. Запуск Node.js REPL"
cat <<'CMD'
docker run -it --rm node:alpine node
console.log('Hello from Docker!');
.exit
CMD

step "3. Запуск файла index.js из каталога задания"
cat <<'CMD'
docker run --rm -v "$(pwd)":/app -w /app node:alpine node index.js
CMD

step "4. Однострочный вариант из источника"
cat <<'CMD'
docker run --rm node:alpine node -e "console.log('Hello')"
CMD

step "Очистка"
cat <<'CMD'
docker stop node-js || true
docker rm -f node-js || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
