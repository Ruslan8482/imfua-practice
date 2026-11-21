# 08. HomeHub (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [Homehub.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/Homehub.md)
- Апстрим: [surajverma/homehub](https://github.com/surajverma/homehub)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/Homehub.md`

## Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `homehub` (`container_name: homehub`) | `ghcr.io/surajverma/homehub:latest` | `5000` → `5000` | Семейная панель управления (Flask) |

Монтируются (как в источнике):
- `./uploads:/app/uploads`, `./media:/app/media`, `./pdfs:/app/pdfs`, `./data:/app/data`;
- `./config.yml:/app/config.yml:ro` — конфигурация приложения (шаблон уже лежит в каталоге).

Сеть `homehub-network` (bridge). В отличие от источника, `SECRET_KEY` обязателен (нет случайного fallback), что безопаснее.

## Пошаговый запуск

1. Убедитесь, что порт 5000 свободен: `docker compose ls`.
2. Отредактируйте `config.yml` (замените `password: "CHANGE_ME_HOMEHUB_PASSWORD"` или оставьте пустым для входа без пароля).
3. Создайте `.env` и замените `SECRET_KEY`:
   ```bash
   cp .env.example .env
   ```
4. Запуск (первый старт может занять несколько минут):
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```

## Проверка

- Статус: `docker compose ps`; логи: `docker compose logs -f`.
- Приложение: http://localhost:5000
- Вход: пароль из `config.yml` (если не пустой).
- Проверьте создание заметки/списка покупок и появление файлов в `./data`, `./uploads`.

## Остановка и очистка

```bash
docker compose down
docker compose down -v             # удалить volumes проекта
docker compose down --rmi all -v   # полная очистка по образцу источника
# или: bash commands.sh clean
```

> Данные лежат в bind-монтах (`./data`, `./uploads`, ...), поэтому `down -v` их не удаляет —
> при необходимости удалите каталоги вручную.

## Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервиса: `<вставить вывод docker compose ps>`
- Проверенные функции: `<заполнить>`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/homehub.png`):

![Скриншот HomeHub](evidence/homehub.png)
