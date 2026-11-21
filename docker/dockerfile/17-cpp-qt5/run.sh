#!/usr/bin/env bash
set -euo pipefail
xhost +local:docker
docker run --rm -it \
  -e DISPLAY="$DISPLAY" \
  -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  imfua-qt5
