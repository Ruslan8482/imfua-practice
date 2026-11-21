FROM rust:1-slim-bookworm AS builder
WORKDIR /app
COPY Cargo.toml .
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -f target/release/rust-app target/release/deps/rust_app-*
COPY src ./src
RUN cargo build --release

FROM debian:bookworm-slim
RUN useradd --create-home appuser
WORKDIR /home/appuser
COPY --from=builder /app/target/release/rust-app ./rust-app
USER appuser
CMD ["./rust-app"]
