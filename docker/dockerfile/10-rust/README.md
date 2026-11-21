### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Rust.md)

# 10. Dockerfile. Приложение на Rust

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [Rust.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Rust.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
10-rust/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── Cargo.toml
└── src/
    └── main.rs
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/10-rust
docker build -t imfua-rust .
docker run -it --rm imfua-rust
```

## ✅ Проверка

```bash
docker run -it --rm imfua-rust
docker run -it --rm --entrypoint sh imfua-rust
# внутри контейнера: ./rust-app
```

Ожидаемый вывод: `Hello from Rust inside Docker! 🦀`.

## 🧰 Порты

Порты не используются.

Для стабильной сборки образы `rust:1-slim-bookworm` и `debian:bookworm-slim`
зафиксированы на одной базе glibc (в источнике — `rust:1-slim` и `debian:stable-slim`).

## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-rust`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
