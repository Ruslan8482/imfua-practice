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
  *) echo "Использование: $0 {up|ps|logs [service]|down|clean|config}" >&2; exit 2 ;;
esac
