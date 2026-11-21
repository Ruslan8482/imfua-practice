### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Pcb2gcode.md)

# 22. Pcb2gcode (insolante)

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

## 🧰 Что за образ

Веб-обёртка над pcb2gcode: загрузка Gerber-файлов, получение g-кода для гравировки и обработки печатной платы.

- **Образ(ы):** `ngargaud/insolante`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `8081` | `5000` | веб-приложение |
| `8180` | `8180` | RPORT (внутренний redirected port) |

### Переменные окружения

| Переменная | Пример/заглушка | Назначение |
|---|---|---|
| `URL` | `http://localhost` | базовый URL приложения |
| `RPORT` | `8180` | дополнительный порт |
| `DEBUG` | `false` | режим отладки |

> Перед запуском скопируйте `environment.env.example` в `environment.env` и замените пароли-заглушки.

## 🧰 Предварительные требования

- WSL, другой полноценный Linux либо Git-Bash/Linux/Mac; для части команд — Windows PowerShell.
- Свободные порты из таблицы выше (проверять до запуска).
- Рекомендуется начать с «чистого листа»: остановить и удалить ненужные учебные контейнеры и образы.
- Никогда не используйте русские имена файлов/каталогов, пробелы и спецсимволы в путях проекта.

```shell
docker version
docker ps -a
```

## 📋 Пошаговое выполнение

### 1. Подготовка каталога данных (Linux/Git-Bash/macOS)

```shell
mkdir -p ~/insolante_data
```

### 2. Подготовка каталога данных (Windows PowerShell)

```shell
mkdir C:\insolante_data -Force
```

### 3. Загрузка образа

```shell
docker pull ngargaud/insolante
```

### 4. Запуск (Git-Bash/Linux/WSL/Mac)

```shell
docker run --rm -p 8081:5000 -d \
  -e URL=http://localhost \
  -e RPORT=8180 \
  -e DEBUG=false \
  -v ~/insolante_data:/opt/core/data \
  ngargaud/insolante
```

### 5. Вариант для Windows PowerShell

```shell
docker run --rm -p 8081:5000 -d `
  -e URL=http://localhost `
  -e RPORT=8180 `
  -e DEBUG=false `
  -v ~/insolante_data:/opt/core/data `
  ngargaud/insolante
```

### 6. Проверка работы

```shell
docker ps
curl -I http://localhost:8081/
# открыть http://localhost:8081 и войти в админ-панель с простым паролем, например 123
```

### Очистка контейнера

```shell
docker stop ngargaud-insolante || true
docker rm -f ngargaud-insolante || true
```

## ✅ Проверка работы (кратко)

- `docker ps` — контейнер в статусе `Up` (для `--rm`-контейнеров проверка во время работы).
- `curl <адрес>` или браузер — страница/ответ сервиса.
- `docker logs <имя>` — отсутствие ошибок в логах.
- `docker exec -it <имя> ...` — проверка изнутри контейнера (где предусмотрено заданием).

## 📊 Результаты

> Заполняется вручную после реального запуска. В этой среде Docker недоступен,
> поэтому фактические выходные данные и скриншоты пока отсутствуют.

| Проверка | Ожидаемый результат | Фактический вывод (заполнить) |
|---|---|---|
| `docker ps` | контейнер запущен | `<!-- вставить вывод -->` |
| `curl` / браузер | корректный ответ сервиса | `<!-- вставить вывод -->` |
| `docker logs` / `docker exec` | ошибок нет | `<!-- вставить вывод -->` |

**Место под скриншот:**

![Скриншот результата — 22-pcb2gcode](evidence/22-pcb2gcode.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## 🔗 Источник

- Оригинальная инструкция: [Pcb2gcode.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Pcb2gcode.md)
- Реестр заданий: ](../../../TASKS.md)
- Обзор трека: ](../../../README.md)

### Полезные ссылки

- https://hub.docker.com/r/ngargaud/insolante

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
