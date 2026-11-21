#!/usr/bin/env bash
# 08-metasploitable2: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull tleemcjr/metasploitable2
CMD

step "2. Запуск и вход (Windows)"
cat <<'CMD'
docker run --name metasploitable2 -it tleemcjr/metasploitable2
CMD

step "3. Запуск и вход (Linux: старт сервисов + bash)"
cat <<'CMD'
docker run --name metasploitable2 -it tleemcjr/metasploitable2:latest sh -c "/bin/services.sh && bash"
CMD

step "4. Проверка работы внутри контейнера"
cat <<'CMD'
hostname
uname -a
ps aux | head -20
CMD

step "5. Выход из контейнера"
cat <<'CMD'
exit
CMD

step "6. Удаление образа (опционально)"
cat <<'CMD'
docker rmi tleemcjr/metasploitable2
CMD

step "Очистка"
cat <<'CMD'
docker stop metasploitable2 || true
docker rm -f metasploitable2 || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
