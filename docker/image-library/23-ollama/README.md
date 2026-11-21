# 23. Ollama / Open WebUI

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

> ## ⚠️ Предупреждение
>
> ВНИМАНИЕ: очень тяжёлые образы и модели (многие ГБ); первый запуск и загрузка моделей требуют много места, памяти и времени. Для загрузки моделей может понадобиться VPN. Не публикуйте сервисы в открытый интернет.

> Следуйте инструкции источника и запускайте только в изолированном окружении.

## Что за образ

Локальный запуск больших языковых моделей: Ollama в контейнере, Open WebUI в одном контейнере или связка из двух контейнеров.

- **Образ(ы):** `ollama/ollama, ghcr.io/open-webui/open-webui:ollama, ghcr.io/open-webui/open-webui:main`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `11434` | `11434` | API Ollama |
| `3000` | `8081` | Open WebUI (вариант 2) |
| `8081` | `8080` | Open WebUI (вариант 2, другой порт) |
| `81` | `8080` | Open WebUI (вариант 3) |

### Переменные окружения

| Переменная | Пример/заглушка | Назначение |
|---|---|---|
| `OLLAMA_BASE_URL` | `http://ollama:11434` | адрес Ollama для Open WebUI (вариант 3) |

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

### 1. Вариант 1. Ollama + phi4

```shell
docker run -d -v ollama_data:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run phi4
# выход из чата: /exit или /bye
```

### 2. Вариант 2. Ollama + Open WebUI в одном контейнере

```shell
docker run -d -p 3000:8081 -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
# http://localhost:3000
```

### 3. Вариант 2 с другим портом

```shell
docker run -d -p 8081:8080 \
  -v ollama:/root/.ollama \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:ollama
# http://localhost:8081
```

### 4. Загрузка и список моделей (вариант 2)

```shell
docker exec -it open-webui ollama pull llama3.2:1b
docker exec -it open-webui ollama list
```

### 5. Вариант 3. Два контейнера: Ollama + Open WebUI

```shell
docker stop open-webui || true
docker rm -f open-webui || true
docker run -d \
  --name ollama \
  --restart always \
  -v ollama:/root/.ollama \
  ollama/ollama:latest
docker run -d \
  -p 81:8080 \
  --name open-webui \
  --restart always \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://ollama:11434 \
  --link ollama \
  ghcr.io/open-webui/open-webui:main
```

### 6. Проверка работы и управление моделями (вариант 3)

```shell
docker exec -it ollama ollama pull llama3.2
docker exec -it ollama ollama list
docker exec -it ollama ollama rm llama3.2
curl -I http://localhost:81/
# или открыть http://localhost:81 в браузере
```

### 7. Опционально: полная очистка Open WebUI

```shell
docker stop open-webui || true
docker rm -f open-webui || true
# ВНИМАНИЕ: удаляет кэш и настройки интерфейса
docker volume rm open-webui || true
```

### Очистка контейнера

```shell
docker stop ollama open-webui || true
docker rm -f ollama open-webui || true
# Тома удаляются только при согласии: docker volume rm ollama_data ollama open-webui
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

![Скриншот результата — 23-ollama](evidence/23-ollama.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## Источник

- Оригинальная инструкция: [Ollama.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Ollama.md)
- Реестр заданий: [TASKS.md § Docker CLI, п. 23](../../TASKS.md)
- Обзор трека: [docker/README.md](../README.md)

### Полезные ссылки

- https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/tree/main

> Если вы обнаружили ошибку в этом тексте — сообщите автору исходной инструкции.
