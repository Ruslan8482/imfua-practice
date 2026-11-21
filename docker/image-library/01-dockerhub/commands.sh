#!/usr/bin/env bash
# 01-dockerhub: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Проверка Docker"
cat <<'CMD'
docker version
docker ps -a
CMD

step "2. Поиск образа в Docker Hub"
cat <<'CMD'
docker search nginx
CMD

step "3. Загрузка образа (pull)"
cat <<'CMD'
docker pull hello-world
CMD

step "4. Запуск демо-образа"
cat <<'CMD'
docker run --rm hello-world
CMD

step "5. Просмотр загруженных образов и метаданных"
cat <<'CMD'
docker images
docker inspect hello-world
CMD

step "6. Пример запуска веб-сервера из образа с Docker Hub"
cat <<'CMD'
docker run -d --name my-nginx -p 80:80 nginx:alpine
docker ps
curl http://localhost/
CMD

step "7. Заход в контейнер (exec)"
cat <<'CMD'
docker exec -it my-nginx /bin/sh
uname -a
cat /etc/os-release
exit
CMD

step "Очистка"
cat <<'CMD'
docker stop my-nginx || true
docker rm -f my-nginx || true
docker rmi hello-world || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
