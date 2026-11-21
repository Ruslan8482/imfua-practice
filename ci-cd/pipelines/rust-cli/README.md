### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Rust_CI_1.md)

# Rust CLI CI (`ci-rust-cli.yml`)

Источник: [Rust_CI_1.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Rust_CI_1.md)

## 🎯 Что делает пайплайн

1. Проверяет форматирование `cargo fmt --all -- --check`.
2. Запускает `cargo clippy --all-targets -- -D warnings`.
3. Выполняет `cargo check`, debug/release-сборки и `cargo test`.
4. Собирает Docker-образ, сохраняет его артефактом и делает smoke-тест.

## 📋 Локальный запуск

```bash
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings
cargo test
cargo run --release
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
