#!/usr/bin/env bash
# 22-pcb2gcode: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Подготовка каталога данных (Linux/Git-Bash/macOS)"
cat <<'CMD'
mkdir -p ~/insolante_data
CMD

step "2. Подготовка каталога данных (Windows PowerShell)"
cat <<'CMD'
mkdir C:\insolante_data -Force
CMD

step "3. Загрузка образа"
cat <<'CMD'
docker pull ngargaud/insolante
CMD

step "4. Запуск (Git-Bash/Linux/WSL/Mac)"
cat <<'CMD'
docker run --rm -p 8081:5000 -d \
  -e URL=http://localhost \
  -e RPORT=8180 \
  -e DEBUG=false \
  -v ~/insolante_data:/opt/core/data \
  ngargaud/insolante
CMD

step "5. Вариант для Windows PowerShell"
cat <<'CMD'
docker run --rm -p 8081:5000 -d `
  -e URL=http://localhost `
  -e RPORT=8180 `
  -e DEBUG=false `
  -v ~/insolante_data:/opt/core/data `
  ngargaud/insolante
CMD

step "6. Проверка работы"
cat <<'CMD'
docker ps
curl -I http://localhost:8081/
# открыть http://localhost:8081 и войти в админ-панель с простым паролем, например 123
CMD

step "Очистка"
cat <<'CMD'
docker stop ngargaud-insolante || true
docker rm -f ngargaud-insolante || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
