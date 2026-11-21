# 24. LibreDB Studio

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

## Что за образ

Открытая веб-IDE (MIT) для работы с базами данных: запросы, визуализация и администрирование через браузер.

- **Образ(ы):** `ghcr.io/libredb/libredb-studio:latest`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `3000` | `3000` | веб-интерфейс LibreDB Studio |

### Переменные окружения

| Переменная | Пример/заглушка | Назначение |
|---|---|---|
| `ADMIN_EMAIL` | `admin@example.com` | e-mail администратора (заглушка) |
| `ADMIN_PASSWORD` | `CHANGE_ME_ADMIN_PASSWORD` | пароль администратора (заглушка) |
| `JWT_SECRET` | `CHANGE_ME_32_CHAR_RANDOM_SECRET` | секрет подписи JWT (заглушка) |

> Перед запуском скопируйте `environment.env.example` в `environment.env` и замените пароли-заглушки.

## Предварительные требования

- WSL, другой полноценный Linux либо Git-Bash/Linux/Mac; для части команд — Windows PowerShell.
- Свободные порты из таблицы выше (проверять до запуска).
- Рекомендуется начать с «чистого листа»: остановить и удалить ненужные учебные контейнеры и образы.
- Никогда не используйте русские имена файлов/каталогов, пробелы и спецсимволы в путях проекта.

```shell
docker version
docker ps -a
```

## Пошаговое выполнение

### 1. Загрузка образа

```shell
docker pull ghcr.io/libredb/libredb-studio:latest
```

### 2. Быстрый запуск (credentials генерируются в консоли)

```shell
docker run -p 3000:3000 ghcr.io/libredb/libredb-studio:latest
```

### 3. Запуск с заданными e-mail и паролем (Git-Bash/Linux)

```shell
docker run -d \
  --name libredb-studio \
  -p 3000:3000 \
  -e ADMIN_EMAIL=admin@example.com \
  -e ADMIN_PASSWORD=YourStrongPassword \
  -e JWT_SECRET=your-random-32-char-secret-string \
  ghcr.io/libredb/libredb-studio:latest
```

### 4. Проверка работы

```shell
docker ps
docker logs libredb-studio
curl -I http://localhost:3000/
# или открыть http://localhost:3000 в браузере и войти через Sign In
```

### 5. Выход из foreground-запуска

```text
Ctrl+C
```

### Очистка контейнера

```shell
docker stop libredb-studio || true
docker rm -f libredb-studio || true
docker image rm ghcr.io/libredb/libredb-studio:latest || true
```

## Проверка работы (кратко)

- `docker ps` — контейнер в статусе `Up` (для `--rm`-контейнеров проверка во время работы).
- `curl <адрес>` или браузер — страница/ответ сервиса.
- `docker logs <имя>` — отсутствие ошибок в логах.
- `docker exec -it <имя> ...` — проверка изнутри контейнера (где предусмотрено заданием).

## Результаты

> Заполняется вручную после реального запуска. В этой среде Docker недоступен,
> поэтому фактические выходные данные и скриншоты пока отсутствуют.

| Проверка | Ожидаемый результат | Фактический вывод (заполнить) |
|---|---|---|
| `docker ps` | контейнер запущен | `<!-- вставить вывод -->` |
| `curl` / браузер | корректный ответ сервиса | `<!-- вставить вывод -->` |
| `docker logs` / `docker exec` | ошибок нет | `<!-- вставить вывод -->` |

**Место под скриншот:**

![Скриншот результата — 24-libredb-studio](evidence/24-libredb-studio.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## Источник

- Оригинальная инструкция: [LibreDB_Studio.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/LibreDB_Studio.md)
- Реестр заданий: [TASKS.md § Docker CLI, п. 24](../../TASKS.md)
- Обзор трека: [docker/README.md](../README.md)

### Полезные ссылки

- https://www.opennet.ru/opennews/art.shtml?num=66216

> Если вы обнаружили ошибку в этом тексте — сообщите автору исходной инструкции.
