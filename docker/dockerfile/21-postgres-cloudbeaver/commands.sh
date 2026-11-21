#!/usr/bin/env bash
set -euo pipefail

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Создан .env из .env.example — при необходимости замените пароли."
fi

build()  { docker compose build; }
up()     { docker compose up -d --build; docker compose ps; }
down()   { docker compose down; }
logs()   { docker compose logs --tail=100; }
clean()  { docker compose down -v --remove-orphans; }

case "${1:-all}" in
  build) build ;;
  up)    up ;;
  logs)  logs ;;
  down)  down ;;
  clean) clean ;;
  all)   up ;;
  *)
    echo "Использование: $0 {build|up|logs|down|clean|all}" >&2
    exit 1
    ;;
esac
