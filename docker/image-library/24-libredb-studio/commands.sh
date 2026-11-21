#!/usr/bin/env bash
# 24-libredb-studio: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull ghcr.io/libredb/libredb-studio:latest
CMD

step "2. Быстрый запуск (credentials генерируются в консоли)"
cat <<'CMD'
docker run -p 3000:3000 ghcr.io/libredb/libredb-studio:latest
CMD

step "3. Запуск с заданными e-mail и паролем (Git-Bash/Linux)"
cat <<'CMD'
docker run -d \
  --name libredb-studio \
  -p 3000:3000 \
  -e ADMIN_EMAIL=admin@example.com \
  -e ADMIN_PASSWORD=YourStrongPassword \
  -e JWT_SECRET=your-random-32-char-secret-string \
  ghcr.io/libredb/libredb-studio:latest
CMD

step "4. Проверка работы"
cat <<'CMD'
docker ps
docker logs libredb-studio
curl -I http://localhost:3000/
# или открыть http://localhost:3000 в браузере и войти через Sign In
CMD

step "5. Выход из foreground-запуска"
cat <<'CMD'
Ctrl+C
CMD

step "Очистка"
cat <<'CMD'
docker stop libredb-studio || true
docker rm -f libredb-studio || true
docker image rm ghcr.io/libredb/libredb-studio:latest || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
