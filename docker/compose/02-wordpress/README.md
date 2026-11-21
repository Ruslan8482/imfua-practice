### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/WordPress.md)

# 02. WordPress (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [WordPress.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/WordPress.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/WordPress.md`

## 🧰 Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `db` | `mysql:8.0` | — (только внутри сети) | База данных WordPress |
| `wordpress` | `wordpress:latest` | `8081` → `80` | CMS с веб-установщиком |

Сеть: `wp-network` (bridge). Тома: `db_data` (БД), `wordpress_data` (файлы, темы, загрузки).

## 📋 Пошаговый запуск

1. Проверьте свободные порты и состояние других проектов: `docker compose ls`.
2. Скопируйте шаблон окружения и замените пароли-заглушки:
   ```bash
   cp .env.example .env
   ```
3. Запустите стек:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```
4. Дождитесь `healthy` у `db`, затем откройте установку WordPress в браузере.

## ✅ Проверка

- Статус: `docker compose ps` — `db` и `wordpress` в статусе `Up`.
- Логи: `docker compose logs -f wordpress`, `docker compose logs db`.
- Сайт и мастер установки: http://localhost:8081
- Параметры БД: хост `db`, база/пользователь/пароль — из `.env`.

## 🧹 Остановка и очистка

```bash
docker compose down
docker compose down -v   # удалит тома: БД и файлы сайта будут потеряны
# или: bash commands.sh clean
```

## 📊 Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервисов: `<вставить вывод docker compose ps>`
- Адрес сайта: `http://localhost:8081`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/wordpress.png`):

![Скриншот WordPress](evidence/wordpress.png)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
