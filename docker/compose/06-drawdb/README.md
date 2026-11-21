# 06. drawDB (Docker Compose)

> **Важно:** в среде preparation Docker отсутствует. Конфигурация проверена статически,
> реальный запуск (`docker compose up -d`) выполняется на машине с Docker/WSL.

- Оригинал: [drawDB.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/drawDB.md)
- Апстрим: [drawdb-io/drawdb](https://github.com/drawdb-io/drawdb) (его `compose.yml` — основа этого задания)
- Локальная копия источника: `/tmp/opencode/imfua-src/content/Docker/DockerCompose/drawDB.md`

## Состав сервисов

| Сервис | Образ | Порт хоста | Назначение |
|---|---|---|---|
| `drawdb` | `node:20-alpine` (${DRAWDB_IMAGE}) | `5173` → `5173` | Редактор ER-диаграмм и генератор SQL (dev-сервер Vite) |

- Bind-монт `./app:/var/www/html`: в каталоге `app/` должны лежать исходники апстрима
  (в исходном `compose.yml` монтируется весь каталог репозитория).
- Сеть `drawdb-network` (driver `bridge`) — как `default: driver: bridge` в апстриме.
- Нет томов с данными БД: drawDB работает в браузере, диаграммы сохраняются локально/через экспорт.

## Пошаговый запуск

1. Проверьте, что порт 5173 свободен: `docker compose ls`.
2. Положите исходники drawDB в `./app`:
   ```bash
   rm -f app/.gitkeep
   git clone --depth 1 https://github.com/drawdb-io/drawdb.git app
   ```
3. Подготовьте окружение:
   ```bash
   cp .env.example .env
   ```
4. Запуск (первый раз `npm install` внутри контейнера занимает несколько минут):
   ```bash
   docker compose up -d
   # или: bash commands.sh up
   ```

## Проверка

- Статус: `docker compose ps` (healthcheck становится healthy после старта Vite).
- Логи: `docker compose logs -f drawdb`.
- Приложение: http://localhost:5173
- Постройте простую ER-диаграмму и экспортируйте SQL — результат зафиксируйте в отчёте.

## Остановка и очистка

```bash
docker compose down
docker compose down -v             # удалить volumes проекта
docker compose down --rmi all -v   # полная очистка по образцу источника
# или: bash commands.sh clean
```

> Исходники в `./app` и артефакты `npm` — bind-монт, `down -v` их не удаляет.

## Результаты

- Дата запуска: `<заполнить при реальном запуске>`
- Статус сервиса: `<вставить вывод docker compose ps>`
- Экспортированная ER-диаграмма/SQL: `<вставить или приложить>`
- Замечания: `<заполнить>`

Скриншот (замените этот блок реальным файлом, например `evidence/drawdb.png`):

![Скриншот drawDB](evidence/drawdb.png)
