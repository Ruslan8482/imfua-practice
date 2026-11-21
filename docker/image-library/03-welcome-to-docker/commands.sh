#!/usr/bin/env bash
# 03-welcome-to-docker: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Проверка, свободен ли порт 8088"
cat <<'CMD'
# Linux/Mac/WSL
netstat -tuln | grep :8088
# Windows
netstat -aon | findstr :8088
CMD

step "2. Загрузка и запуск контейнера"
cat <<'CMD'
docker pull docker/welcome-to-docker
docker run -d -p 8088:80 --name welcome-to-docker docker/welcome-to-docker
CMD

step "3. Проверка работы"
cat <<'CMD'
docker ps
curl http://localhost:8088/
# или открыть http://localhost:8088 в браузере
CMD

step "4. Вход в контейнер"
cat <<'CMD'
docker exec -it welcome-to-docker /bin/sh
# для Git-Bash/MSYS при необходимости:
# MSYS_NO_PATHCONV=1 docker exec -it welcome-to-docker /bin/sh
CMD

step "5. Команды внутри контейнера"
cat <<'CMD'
uname -a
cat /etc/os-release
top
tree
apk update && apk upgrade
apk add fastfetch
fastfetch
exit
CMD

step "Очистка"
cat <<'CMD'
docker stop welcome-to-docker || true
docker rm -f welcome-to-docker || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
