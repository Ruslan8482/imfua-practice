### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_Rust.md)

# Rust CLI → GHCR (`cd-rust-ghcr.yml`)

Источник: [CI_CD_Rust.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_Rust.md)

## 🎯 Что делает пайплайн

1. Запускает `fmt`, `clippy` и тесты Rust.
2. При `push` в main логинится в GHCR через `docker/login-action@v3`.
3. Формирует теги через `docker/metadata-action@v5`.
4. Публикует образ через `docker/build-push-action@v6`; для PR — только сборка.

## 📋 Локальный запуск

```bash
cargo clippy --all-targets -- -D warnings
cargo test
docker build -t rust-ghcr .
docker run --rm rust-ghcr
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** и страницы пакета GHCR.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
