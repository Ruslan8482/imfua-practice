#!/usr/bin/env bash
set -euo pipefail

IMAGE="imfua-qt5"
CONTAINER="imfua-qt5"

build() {
  docker build -t "$IMAGE" .
}

run() {
  echo "GUI: xhost +local:docker && docker run --rm -it -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix:rw \"$IMAGE\""
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
