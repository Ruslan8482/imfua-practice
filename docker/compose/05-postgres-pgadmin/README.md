# 05. PostgreSQL + pgAdmin (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [PostgreSQL_pgAdmin.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgreSQL_pgAdmin.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/PostgreSQL_pgAdmin.md`

## Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `postgres` (`postgres-db`) | `postgres:17-alpine` | `5432` → `5432` | СУБД PostgreSQL |
| `pgadmin` (`pgadmin-web`) | `dpage/pgadmin4:latest` | `5050` → `80` | Веб-интерфейс pgAdmin 4 |

Сеть: `postgres-pgadmin-network` (bridge). Тома: `postgres_data` (БД), `pgadmin_data` (настройки pgAdmin, добавлено сверх источника).

## Пошаговый запуск

1. Проверьте свободность портов 5432/5050: `docker compose ls`.
2. Скопируйте шаблон и замените пароли/email:
   ```bash
   cp .env.example .env
   ```
3. Запуск:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```
4. Дождитесь статуса `Up`/`healthy`: `docker compose ps -a`.

## Проверка

- pgAdmin: http://localhost:5050
- Логин pgAdmin: email и пароль из `.env` (по умолчанию в шаблоне `admin@example.com` / заглушка).
- Добавьте сервер: General → имя любое; Connection → Host `postgres-db` (или `postgres`), Port `5432`,
  Maintenance database `mydatabase`, Username/Password — из `.env`.
- Логи: `docker compose logs -f pgadmin`, `docker compose logs postgres`.

## Остановка и очистка

```bash
docker compose down
docker compose down -v   # удалит данные БД и настройки pgAdmin
# или: bash commands.sh clean
```

## Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервисов: `<вставить вывод docker compose ps>`
- Успешное подключение сервера в pgAdmin: `<заполнить>`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/pgadmin.png`):

![Скриншот pgAdmin](evidence/pgadmin.png)
