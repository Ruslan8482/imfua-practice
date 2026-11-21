#!/usr/bin/env bash
set -euo pipefail

IMAGE="imfua-nginx-site"
CONTAINER="imfua-nginx-site"

build() {
  docker build -t "$IMAGE" .
}

run() {
  docker rm -f "$CONTAINER" 2>/dev/null || true
  docker run -d -p 8081:80 --name "$CONTAINER" "$IMAGE"
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
