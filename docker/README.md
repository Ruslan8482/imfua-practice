### [Вернуться на Главную](../README.md)

## Навигация

- [Реестр заданий](../TASKS.md)
- [Архитектура](../ARCHITECTURE.md)

# Docker

Три трека из репозитория `rurewa/imfua`:

| Трек | Каталог | Заданий | Что внутри |
|------|---------|---------|------------|
| Docker CLI / ImageLibrary | `image-library/` | 24 | готовые команды `docker pull/run/exec`, проверки, шаблон отчёта |
| Dockerfile | `dockerfile/` | 21 | `Dockerfile`, исходники приложения, `.dockerignore`, команды сборки |
| Docker Compose | `compose/` | 9 | `compose.yaml`, `.env.example`, команды запуска |

Каждое задание — отдельный каталог `NN-slug/` с `README.md` (цели, шаги, команды,
результаты, место под скриншоты). Источники перечислены в [TASKS.md](../TASKS.md).

## 🧰 Запуск

```bash
cd docker/image-library/02-nginx && bash commands.sh
cd docker/dockerfile/03-python && docker build -t imfua-python . && docker run --rm imfua-python
cd docker/compose/03-mysql-phpmyadmin && docker compose up -d
```

## ⚠️ Важно

Опасные задания (Metasploitable2, Jira, Ollama и тяжёлые образы) запускайте только
по инструкции источника и только в изолированном окружении. Секреты хранятся в
`.env.example` — перед запуском скопируйте его в `.env` и замените пароли.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
