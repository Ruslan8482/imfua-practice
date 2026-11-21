### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/mySQLphpMyAdmin.md)

# 03. MySQL + phpMyAdmin (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [mySQLphpMyAdmin.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/mySQLphpMyAdmin.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/mySQLphpMyAdmin.md`

## 🧰 Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `mysql` | `mysql:8.0` | `3306` → `3306` | СУБД MySQL |
| `phpmyadmin` | `phpmyadmin/phpmyadmin:latest` | `8083` → `80` | Веб-интерфейс администрирования |

Сеть: `mysql-pma-network` (bridge). Том: `mysql_data` (данные БД).

## 📋 Пошаговый запуск

1. Убедитесь, что порты 3306 и 8083 свободны: `docker compose ls`.
2. Подготовьте `.env` (все пароли в шаблоне — заглушки):
   ```bash
   cp .env.example .env
   ```
3. Запуск:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```
4. Дождитесь готовности MySQL (`service_healthy` у phpMyAdmin).

## ✅ Проверка

- Статус: `docker compose ps -a`.
- phpMyAdmin: http://localhost:8083
- Сервер в форме входа: `mysql` (или `localhost:3306`), пользователь `root`, пароль из `.env`.
- Логи: `docker compose logs -f phpmyadmin`, `docker compose logs mysql`.
- Вход в контейнер БД: `docker compose exec mysql bash`.

## 🧹 Остановка и очистка

```bash
docker compose down
docker compose down -v   # удалит и данные БД
# или: bash commands.sh clean
```

## 📊 Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервисов: `<вставить вывод docker compose ps>`
- Доступ: `http://localhost:8083`, сервер `mysql`, пользователь `root`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/mysql-pma.png`):

![Скриншот phpMyAdmin](evidence/mysql-pma.png)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
