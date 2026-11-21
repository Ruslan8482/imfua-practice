FROM gcc:13 AS build

WORKDIR /src
COPY . .
RUN g++ -std=c++17 -O2 -o /out/hello-cpp src/main.cpp src/sum.cpp

FROM debian:bookworm-slim

COPY --from=build /out/hello-cpp /usr/local/bin/hello-cpp
ENTRYPOINT ["hello-cpp"]
