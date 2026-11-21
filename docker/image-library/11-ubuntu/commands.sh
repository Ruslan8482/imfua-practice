#!/usr/bin/env bash
# 11-ubuntu: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull ubuntu:latest
CMD

step "2. Запуск и вход (--rm — автоматическое удаление)"
cat <<'CMD'
docker run -it --rm ubuntu:latest /bin/bash
CMD

step "3. Если загрузка прервалась ошибкой TLS — повторите команду"
cat <<'CMD'
Unable to find image 'ubuntu:latest' locally
docker: Error response from daemon: Get "https://registry-1.docker.io/v2/library/ubuntu/manifests/...": net/http: TLS handshake timeout
CMD

step "4. Установка утилиты внутри контейнера"
cat <<'CMD'
apt update && apt install neofetch
# если neofetch не находится:
apt update && apt install fastfetch
fastfetch
CMD

step "5. Выход (контейнер будет удалён автоматически)"
cat <<'CMD'
exit
docker ps -a
CMD

step "Очистка"
cat <<'CMD'
docker stop ubuntu || true
docker rm -f ubuntu || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
