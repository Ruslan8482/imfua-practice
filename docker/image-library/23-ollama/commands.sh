#!/usr/bin/env bash
# 23-ollama: команды задания (pull -> run -> проверка -> cleanup).
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

step "1. Вариант 1. Ollama + phi4"
cat <<'CMD'
docker run -d -v ollama_data:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run phi4
# выход из чата: /exit или /bye
CMD

step "2. Вариант 2. Ollama + Open WebUI в одном контейнере"
cat <<'CMD'
docker run -d -p 3000:8081 -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
# http://localhost:3000
CMD

step "3. Вариант 2 с другим портом"
cat <<'CMD'
docker run -d -p 8081:8080 \
  -v ollama:/root/.ollama \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:ollama
# http://localhost:8081
CMD

step "4. Загрузка и список моделей (вариант 2)"
cat <<'CMD'
docker exec -it open-webui ollama pull llama3.2:1b
docker exec -it open-webui ollama list
CMD

step "5. Вариант 3. Два контейнера: Ollama + Open WebUI"
cat <<'CMD'
docker stop open-webui || true
docker rm -f open-webui || true
docker run -d \
  --name ollama \
  --restart always \
  -v ollama:/root/.ollama \
  ollama/ollama:latest
docker run -d \
  -p 81:8080 \
  --name open-webui \
  --restart always \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://ollama:11434 \
  --link ollama \
  ghcr.io/open-webui/open-webui:main
CMD

step "6. Проверка работы и управление моделями (вариант 3)"
cat <<'CMD'
docker exec -it ollama ollama pull llama3.2
docker exec -it ollama ollama list
docker exec -it ollama ollama rm llama3.2
curl -I http://localhost:81/
# или открыть http://localhost:81 в браузере
CMD

step "7. Опционально: полная очистка Open WebUI"
cat <<'CMD'
docker stop open-webui || true
docker rm -f open-webui || true
# ВНИМАНИЕ: удаляет кэш и настройки интерфейса
docker volume rm open-webui || true
CMD

step "Очистка"
cat <<'CMD'
docker stop ollama open-webui || true
docker rm -f ollama open-webui || true
# Тома удаляются только при согласии: docker volume rm ollama_data ollama open-webui
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
