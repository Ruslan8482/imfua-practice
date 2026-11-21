### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Portainer.md)

# 16. Portainer

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

> ## ⚠️ Предупреждение
>
> Контейнер получает доступ к /var/run/docker.sock, то есть к управлению Docker хоста. Используйте только в доверенном учебном окружении и задайте надёжный пароль администратора.

> Следуйте инструкции источника и запускайте только в изолированном окружении.

## 🧰 Что за образ

Графический интерфейс управления Docker: контейнеры, образы, сети, тома и стеки. Использует сокет Docker хоста и именованный том для данных.

- **Образ(ы):** `portainer/portainer-ce:latest`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `9000` | `9000` | HTTP UI |
| `9443` | `9443` | HTTPS UI |

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

### 1. Загрузка образа

```shell
docker pull portainer/portainer-ce:latest
```

### 2. Запуск с томами (Git-Bash/Linux/WSL/Mac)

```shell
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart unless-stopped \
  portainer/portainer-ce:latest
```

### 3. Вариант для Windows PowerShell

```shell
docker run -d `
  --name portainer `
  -p 9000:9000 `
  -p 9443:9443 `
  -v /var/run/docker.sock:/var/run/docker.sock `
  -v portainer_data:/data `
  --restart unless-stopped `
  portainer/portainer-ce:latest
```

### 4. Проверка работы

```shell
docker ps
curl -I http://localhost:9000/
# или открыть http://localhost:9000 в браузере
```

### 5. Логи и токен/setup-пароль

```shell
docker logs portainer
# при отсутствии окна создания пароля:
docker run --rm -v portainer_data:/data portainer/helper-reset-password
```

### 6. Вариант без setup-токена

```shell
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart unless-stopped \
  portainer/portainer-ce:latest \
  --no-setup-token
```

### Очистка контейнера

```shell
docker stop portainer || true
docker rm -f portainer || true
# ВНИМАНИЕ: следующая команда удалит بيانات Portainer
docker volume rm portainer_data || true
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

![Скриншот результата — 16-portainer](evidence/16-portainer.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## 🔗 Источник

- Оригинальная инструкция: [Portainer.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Portainer.md)
- Реестр заданий: ](../../../TASKS.md)
- Обзор трека: ](../../../README.md)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
