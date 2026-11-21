#!/usr/bin/env bash
# 16-portainer: команды задания (pull -> run -> проверка -> cleanup).
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
docker pull portainer/portainer-ce:latest
CMD

step "2. Запуск с томами (Git-Bash/Linux/WSL/Mac)"
cat <<'CMD'
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart unless-stopped \
  portainer/portainer-ce:latest
CMD

step "3. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name portainer `
  -p 9000:9000 `
  -p 9443:9443 `
  -v /var/run/docker.sock:/var/run/docker.sock `
  -v portainer_data:/data `
  --restart unless-stopped `
  portainer/portainer-ce:latest
CMD

step "4. Проверка работы"
cat <<'CMD'
docker ps
curl -I http://localhost:9000/
# или открыть http://localhost:9000 в браузере
CMD

step "5. Логи и токен/setup-пароль"
cat <<'CMD'
docker logs portainer
# при отсутствии окна создания пароля:
docker run --rm -v portainer_data:/data portainer/helper-reset-password
CMD

step "6. Вариант без setup-токена"
cat <<'CMD'
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart unless-stopped \
  portainer/portainer-ce:latest \
  --no-setup-token
CMD

step "Очистка"
cat <<'CMD'
docker stop portainer || true
docker rm -f portainer || true
# ВНИМАНИЕ: следующая команда удалит بيانات Portainer
docker volume rm portainer_data || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
