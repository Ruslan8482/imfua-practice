### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Nginx.md)

# 02. Веб-сервер Nginx

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

## 🧰 Что за образ

Полный цикл работы с готовым образом NGINX: поиск, запуск, проверка через curl/браузер, управление контейнером, логи и вход внутрь контейнера.

- **Образ(ы):** `nginx (также nginx:alpine)`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `80` | `80` | основной экземпляр my-nginx |
| `81` | `80` | второй экземпляр nginx-my (опционально) |

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

### 1. Проверка Docker и «чистый лист»

```shell
docker version
docker ps -a
docker stop $(docker ps -q) 2>/dev/null || true
docker container prune -f
```

### 2. Поиск и загрузка образа

```shell
docker search nginx
docker pull nginx
```

### 3. Создание и запуск контейнера (run объединяет pull/create/start)

```shell
docker run -d --name my-nginx -p 80:80 nginx
docker images
docker ps -a
```

### 4. Проверка работы: curl и браузер

```shell
curl http://localhost/
# или открыть http://localhost/ в браузере
```

### 5. Управление контейнером

```shell
docker stop my-nginx
docker start my-nginx
docker restart my-nginx
docker stats --no-stream
docker logs my-nginx
docker logs -f my-nginx   # выход по Ctrl+C
```

### 6. Вход в контейнер и изучение ОС

```shell
docker exec -it my-nginx /bin/bash
uname -a
cat /etc/os-release
apt update && apt install -y fastfetch
fastfetch
exit
```

### 7. Второй контейнер из того же образа (опционально)

```shell
docker run -d --name nginx-my -p 81:80 nginx
curl http://localhost:81/
```

### Очистка контейнера

```shell
docker stop my-nginx nginx-my || true
docker rm -f my-nginx nginx-my || true
docker rmi nginx || true
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

![Скриншот результата — 02-nginx](evidence/02-nginx.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## 🔗 Источник

- Оригинальная инструкция: [Nginx.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Nginx.md)
- Реестр заданий: [TASKS.md § Docker CLI, п. 02](../../TASKS.md)
- Обзор трека: [docker/README.md](../README.md)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
