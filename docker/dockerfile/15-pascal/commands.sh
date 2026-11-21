#!/usr/bin/env bash
set -euo pipefail

IMAGE="imfua-pascal"
CONTAINER="imfua-pascal"

build() {
  docker build -t "$IMAGE" .
}

run() {
  docker run --rm "$IMAGE"
}

logs() {
  docker logs "$CONTAINER"
}

clean() {
  docker rm -f "$CONTAINER" 2>/dev/null || true
  docker rmi -f "$IMAGE" 2>/dev/null || true

}

case "${1:-all}" in
  build) build ;;
  run)   run ;;
  logs)  logs ;;
  clean) clean ;;
  all)   build; run ;;
  *)
    echo "Использование: $0 {build|run|logs|clean|all}" >&2
    exit 1
    ;;
esac
