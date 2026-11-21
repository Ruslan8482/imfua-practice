FROM rust:1.77 AS build

WORKDIR /src
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim

COPY --from=build /src/target/release/rust-ghcr /usr/local/bin/rust-ghcr
ENTRYPOINT ["rust-ghcr"]
