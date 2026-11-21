### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Rust_CI_1.md)

# Rust CLI CI — вариант 1 (`ci-rust-cli-1.yml`)

Источник: [Rust_CI_1.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Rust_CI_1.md)

## 🎯 Что делает пайплайн

1. Запускает `fmt`/`clippy` на Ubuntu.
2. Собирает и тестирует проект на Ubuntu, macOS и Windows через матрицу.
3. Кэширует Cargo через `Swatinem/rust-cache@v2`.
4. Загружает release-бинарник каждой ОС в артефакты.

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
