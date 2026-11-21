#!/usr/bin/env bash
# 06-alt-linux: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Загрузка готового образа"
cat <<'CMD'
docker pull alt:sisyphus
CMD

step "2. Запуск и вход в контейнер (--rm — автоудаление после выхода)"
cat <<'CMD'
docker run -ti --rm --name alt alt:sisyphus /bin/bash
CMD

step "3. Установка и запуск Fastfetch"
cat <<'CMD'
apt-get update && apt-get install fastfetch
fastfetch
CMD

step "4. Выход из контейнера"
cat <<'CMD'
exit
CMD

step "5. Проверка результата"
cat <<'CMD'
docker images alt
docker ps -a
CMD

step "Очистка"
cat <<'CMD'
docker stop alt || true
docker rm -f alt || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
