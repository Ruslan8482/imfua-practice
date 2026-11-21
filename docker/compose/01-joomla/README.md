### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/joomla.md)

# 01. Joomla (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [joomla.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/joomla.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/joomla.md`

## 🧰 Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `db` | `mariadb:11.5.2` | — (только внутри сети) | База данных Joomla |
| `joomla` | `joomla:latest` | `8082` → `80` | CMS с веб-установщиком |

Сеть: `joomla-network` (bridge). Тома: `db_data` (БД), `joomla_data` (файлы CMS).

## 📋 Пошаговый запуск

1. Убедитесь, что порт 8082 свободен и другие compose-проекты не конфликтуют:
   ```bash
   docker compose ls
   ```
2. Подготовьте окружение (значения — заглушки, замените их):
   ```bash
   cp .env.example .env
   ```
3. Поднимите стек:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```
4. Дождитесь готовности БД (healthcheck) и откройте веб-установщик.

## ✅ Проверка

- Статус: `docker compose ps` — оба сервиса `Up (healthy)` / `Up`.
- Логи: `docker compose logs -f joomla`, `docker compose logs db`.
- Сайт: http://localhost:8082
- Админка: http://localhost:8082/administrator
- Параметры БД в установщике: сервер `db`, база `joomla_db`, пользователь/пароль из `.env`.
- Веб-установщик: после установки удалите каталог `installation`, как указано в источнике.

## 🧹 Остановка и очистка

```bash
docker compose down      # остановить и удалить контейнеры/сеть
docker compose down -v   # дополнительно удалить тома (ВСЕ данные сайта и БД)
# или: bash commands.sh clean
```

## 📊 Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервисов: `<вставить вывод docker compose ps>`
- Адрес сайта / админки: `http://localhost:8082` / `http://localhost:8082/administrator`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/joomla.png`):

![Скриншот Joomla](evidence/joomla.png)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
