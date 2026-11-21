### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/CloudBeaver.md)

# 09. CloudBeaver (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [CloudBeaver.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/CloudBeaver.md)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/CloudBeaver.md`

## 🧰 Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `cloudbeaver` (`container_name: cloudbeaver`) | `dbeaver/cloudbeaver:latest` | `8978` → `8978` | Веб-версия DBeaver |

- Bind-монт `./workspace:/opt/cloudbeaver/workspace` — подключения и настройки сохраняются между перезапусками.
- Дополнительно `./logs:/opt/cloudbeaver/logs` (как в апстрим-композе проекта).
- Сеть `cloudbeaver-network` (bridge). Healthcheck не добавлен: в официальном образе нет гарантированного HTTP-клиента для пробы.

## 📋 Пошаговый запуск

1. Проверьте, что порт 8978 свободен: `docker compose ls`.
2. Подготовьте окружение:
   ```bash
   cp .env.example .env
   ```
3. Запуск:
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```
4. При первом входе создайте администратора: имя `cbadmin`, пароль > 8 символов
   с хотя бы одной заглавной и одной строчной буквой (как в источнике).

## ✅ Проверка

- Статус: `docker compose ps -a`; логи: `docker compose logs cloudbeaver`, `docker compose logs -f cloudbeaver`.
- Приложение: http://localhost:8978
- Создайте подключение к тестовой БД и проверьте, что оно сохранилось в `./workspace`.
- Конфигурация: `docker compose config`.

## 🧹 Остановка и очистка

```bash
docker compose down
docker compose down -v   # удалит тома; данные в ./workspace при этом останутся
docker image rm dbeaver/cloudbeaver:latest   # опционально
# или: bash commands.sh clean
```

## 📊 Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервиса: `<вставить вывод docker compose ps>`
- Созданное подключение / результат запроса: `<заполнить>`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/cloudbeaver.png`):

![Скриншот CloudBeaver](evidence/cloudbeaver.png)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
