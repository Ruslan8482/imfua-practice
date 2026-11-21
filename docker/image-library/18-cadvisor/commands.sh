#!/usr/bin/env bash
# 18-cadvisor: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Проверка порта 8082"
cat <<'CMD'
# Linux/Mac/WSL
netstat -tuln | grep :8082
# Windows
netstat -aon | findstr :8082
CMD

step "2. Загрузка образа"
cat <<'CMD'
docker pull lagoudocker/cadvisor:v0.37.0
CMD

step "3. Запуск в Git-Bash/WSL/Linux/Mac"
cat <<'CMD'
docker run -d \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8082:8080 \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  lagoudocker/cadvisor:v0.37.0
CMD

step "4. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --volume=/:/rootfs:ro `
  --volume=/var/run:/var/run:ro `
  --volume=/sys:/sys:ro `
  --volume=/var/lib/docker/:/var/lib/docker:ro `
  --volume=/dev/disk/:/dev/disk:ro `
  --publish=8082:8080 `
  --name=cadvisor `
  --privileged `
  --device=/dev/kmsg `
  lagoudocker/cadvisor:v0.37.0
CMD

step "5. Проверка работы"
cat <<'CMD'
docker ps
docker logs cadvisor
curl -I http://localhost:8082/
# или открыть http://localhost:8082 в браузере
CMD

step "Очистка"
cat <<'CMD'
docker stop cadvisor || true
docker rm -f cadvisor || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
