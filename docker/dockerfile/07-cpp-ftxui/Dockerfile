FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY main.cpp CMakeLists.txt ./
RUN cmake -S . -B build && cmake --build build --parallel

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive TERM=xterm-256color
RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/build/ftxui_demo /usr/local/bin/ftxui_demo
CMD ["ftxui_demo"]
