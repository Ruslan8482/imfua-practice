#!/usr/bin/env bash
# 02-nginx: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Проверка Docker и «чистый лист»"
cat <<'CMD'
docker version
docker ps -a
docker stop $(docker ps -q) 2>/dev/null || true
docker container prune -f
CMD

step "2. Поиск и загрузка образа"
cat <<'CMD'
docker search nginx
docker pull nginx
CMD

step "3. Создание и запуск контейнера (run объединяет pull/create/start)"
cat <<'CMD'
docker run -d --name my-nginx -p 80:80 nginx
docker images
docker ps -a
CMD

step "4. Проверка работы: curl и браузер"
cat <<'CMD'
curl http://localhost/
# или открыть http://localhost/ в браузере
CMD

step "5. Управление контейнером"
cat <<'CMD'
docker stop my-nginx
docker start my-nginx
docker restart my-nginx
docker stats --no-stream
docker logs my-nginx
docker logs -f my-nginx   # выход по Ctrl+C
CMD

step "6. Вход в контейнер и изучение ОС"
cat <<'CMD'
docker exec -it my-nginx /bin/bash
uname -a
cat /etc/os-release
apt update && apt install -y fastfetch
fastfetch
exit
CMD

step "7. Второй контейнер из того же образа (опционально)"
cat <<'CMD'
docker run -d --name nginx-my -p 81:80 nginx
curl http://localhost:81/
CMD

step "Очистка"
cat <<'CMD'
docker stop my-nginx nginx-my || true
docker rm -f my-nginx nginx-my || true
docker rmi nginx || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
