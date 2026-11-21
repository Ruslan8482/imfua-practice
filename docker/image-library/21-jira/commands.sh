#!/usr/bin/env bash
# 21-jira: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull atlassian/jira-software:latest
CMD

step "2. Запуск контейнера"
cat <<'CMD'
docker run -d --name jira -p 2990:8080 atlassian/jira-software:latest
# альтернатива без :latest:
# docker run -d --name jira -p 2990:8080 atlassian/jira-software
CMD

step "3. Наблюдение за инициализацией"
cat <<'CMD'
docker logs -f jira   # выход по Ctrl+C
CMD

step "4. Проверка работы"
cat <<'CMD'
docker ps
curl -I http://localhost:2990/
# или открыть http://localhost:2990 в браузере после завершения подготовки
CMD

step "Очистка"
cat <<'CMD'
docker stop jira || true
docker rm -f jira || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
