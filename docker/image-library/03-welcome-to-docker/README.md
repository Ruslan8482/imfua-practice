### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/WelcomeToDocker.md)

# 03. Welcome to Docker

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

## 🧰 Что за образ

Учебный образ Docker: запуск приветственного сайта, вход в контейнер и изучение минималистичного окружения на базе Alpine.

- **Образ(ы):** `docker/welcome-to-docker`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `8088` | `80` | приветственная страница |

### Переменные окружения

Не используются.

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

### 1. Проверка, свободен ли порт 8088

```shell
# Linux/Mac/WSL
netstat -tuln | grep :8088
# Windows
netstat -aon | findstr :8088
```

### 2. Загрузка и запуск контейнера

```shell
docker pull docker/welcome-to-docker
docker run -d -p 8088:80 --name welcome-to-docker docker/welcome-to-docker
```

### 3. Проверка работы

```shell
docker ps
curl http://localhost:8088/
# или открыть http://localhost:8088 в браузере
```

### 4. Вход в контейнер

```shell
docker exec -it welcome-to-docker /bin/sh
# для Git-Bash/MSYS при необходимости:
# MSYS_NO_PATHCONV=1 docker exec -it welcome-to-docker /bin/sh
```

### 5. Команды внутри контейнера

```shell
uname -a
cat /etc/os-release
top
tree
apk update && apk upgrade
apk add fastfetch
fastfetch
exit
```

### Очистка контейнера

```shell
docker stop welcome-to-docker || true
docker rm -f welcome-to-docker || true
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

![Скриншот результата — 03-welcome-to-docker](evidence/03-welcome-to-docker.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## 🔗 Источник

- Оригинальная инструкция: [WelcomeToDocker.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/WelcomeToDocker.md)
- Реестр заданий: [TASKS.md § Docker CLI, п. 03](../../TASKS.md)
- Обзор трека: [docker/README.md](../README.md)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
