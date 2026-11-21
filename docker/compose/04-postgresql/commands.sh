#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

case "${1:-up}" in
  up)    docker compose up -d ;;
  ps)    docker compose ps ;;
  logs)  if [ -n "${2:-}" ]; then docker compose logs -f "$2"; else docker compose logs -f; fi ;;
  down)  docker compose down ;;
  clean) docker compose down -v ;;
  config) docker compose config ;;
  psql)  docker compose exec postgres psql -U "${POSTGRES_USER:-myuser}" -d "${POSTGRES_DB:-mydatabase}" ;;
  *) echo "Использование: $0 {up|ps|logs [service]|down|clean|config|psql}" >&2; exit 2 ;;
esac
