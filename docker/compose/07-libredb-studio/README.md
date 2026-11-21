### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/LibreDB_Studio.md)

# 07. LibreDB Studio (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [LibreDB_Studio.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/LibreDB_Studio.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/LibreDB_Studio.md`

## 🧰 Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `libredb-studio` | `ghcr.io/libredb/libredb-studio:latest` | `3000` → `3000` | Веб-IDE для работы с БД (SQLite-хранилище) |

- Том `libredb-data` монтируется в `/app/data` (SQLite-файл настроек/подключений).
- Сеть `libredb-network` (bridge).
- healthcheck `wget --spider http://localhost:3000` — как в источнике.

## 📋 Пошаговый запуск

1. Проверьте порт 3000 и имя контейнера:
   ```bash
   ss -tulpn | grep :3000
   docker ps -a | grep libredb-studio
   ```
2. Создайте `.env` и ЗАМЕНИТЕ заглушки (особенно `JWT_SECRET`, минимум 32 символа):
   ```bash
   cp .env.example .env
   ```
3. Запуск:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```

## ✅ Проверка

- Статус: `docker compose ps -a`; логи: `docker compose logs --tail=20 libredb-studio`, `docker compose logs -f`.
- Приложение: http://localhost:3000
- Логин: `ADMIN_EMAIL` и `ADMIN_PASSWORD` из `.env` (по умолчанию `admin@libredb.org` / заглушка).
- Создайте тестовое подключение к БД и выполните запрос — результат зафиксируйте в отчёте.

## 🧹 Остановка и очистка

```bash
docker compose down
docker compose down -v   # удалит том libredb-data (все настройки и подключения)
# или: bash commands.sh clean
```

## 📊 Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус healthcheck: `<вставить вывод docker compose ps>`
- Результат тестового запроса: `<вставить>`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/libredb.png`):

![Скриншот LibreDB Studio](evidence/libredb.png)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
