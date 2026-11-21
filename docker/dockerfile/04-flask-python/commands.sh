#!/usr/bin/env bash
set -euo pipefail

IMAGE="imfua-flask"
CONTAINER="imfua-flask"

build() {
  docker build -t "$IMAGE" .
}

run() {
  docker rm -f "$CONTAINER" 2>/dev/null || true
  docker run -d -p 8082:5000 --name "$CONTAINER" "$IMAGE"
  docker ps --filter "name=$CONTAINER"
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
