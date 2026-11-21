### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgresSQL.md)

# 04. PostgreSQL (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [PostgresSQL.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgresSQL.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/PostgresSQL.md`

## 🧰 Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `postgres` | `postgres:15` | `5432` → `5432` | СУБД PostgreSQL с healthcheck |

- Именованный том `postgres_data` хранит PGDATA (в источнике использовался bind-монт `./data`).
- `./scripts/init.sql` монтируется в `/docker-entrypoint-initdb.d/` и выполняется только при первом создании тома.
- `./backups` монтируется в контейнер для дампов. Пароль в `init.sql` — заглушка `CHANGE_ME_APP_PASSWORD`, замените его при необходимости.

## 📋 Пошаговый запуск

1. Проверьте, что порт 5432 свободен: `docker compose ls`.
2. Создайте `.env` и замените пароль:
   ```bash
   cp .env.example .env
   ```
3. Запуск:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```
4. Убедитесь, что healthcheck зелёный: `docker compose ps`.

## ✅ Проверка

- Статус и здоровье: `docker compose ps`, логи: `docker compose logs -f postgres`.
- Подключение из контейнера: `docker compose exec postgres psql -U myuser -d mydatabase`
  (или `bash commands.sh psql`).
- Хост снаружи: `localhost:5432` (браузер покажет пустую страницу — это ожидаемо для TCP-порта БД).
- Проверка таблицы: `SELECT * FROM users;`

## 🧹 Остановка и очистка

```bash
docker compose down          # данные останутся в томе/каталогах
docker compose down -v       # удалить том postgres_data (данные БД будут потеряны)
# или: bash commands.sh clean
```

## 📊 Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус healthcheck: `<вставить вывод docker compose ps>`
- Результат `SELECT * FROM users;`: `<вставить вывод>`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/postgres.png`):

![Скриншот PostgreSQL](evidence/postgres.png)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
