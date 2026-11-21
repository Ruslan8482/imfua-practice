### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/cAdvisor.md)

# 18. cAdvisor (мониторинг контейнеров)

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

> ## ⚠️ Предупреждение
>
> Контейнер запускается с --privileged и монтирует корень ФС, /var/run, /sys и /var/lib/docker в режиме только для чтения. Запускайте только в изолированном учебном окружении.

> Следуйте инструкции источника и запускайте только в изолированном окружении.

## 🧰 Что за образ

Инструмент Google для сбора метрик и анализа потребления ресурсов запущенными контейнерами.

- **Образ(ы):** `lagoudocker/cadvisor:v0.37.0`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `8082` | `8080` | веб-интерфейс cAdvisor |

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

### 1. Проверка порта 8082

```shell
# Linux/Mac/WSL
netstat -tuln | grep :8082
# Windows
netstat -aon | findstr :8082
```

### 2. Загрузка образа

```shell
docker pull lagoudocker/cadvisor:v0.37.0
```

### 3. Запуск в Git-Bash/WSL/Linux/Mac

```shell
docker run -d \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8082:8080 \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  lagoudocker/cadvisor:v0.37.0
```

### 4. Вариант для Windows PowerShell

```shell
docker run -d `
  --volume=/:/rootfs:ro `
  --volume=/var/run:/var/run:ro `
  --volume=/sys:/sys:ro `
  --volume=/var/lib/docker/:/var/lib/docker:ro `
  --volume=/dev/disk/:/dev/disk:ro `
  --publish=8082:8080 `
  --name=cadvisor `
  --privileged `
  --device=/dev/kmsg `
  lagoudocker/cadvisor:v0.37.0
```

### 5. Проверка работы

```shell
docker ps
docker logs cadvisor
curl -I http://localhost:8082/
# или открыть http://localhost:8082 в браузере
```

### Очистка контейнера

```shell
docker stop cadvisor || true
docker rm -f cadvisor || true
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

![Скриншот результата — 18-cadvisor](evidence/18-cadvisor.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## 🔗 Источник

- Оригинальная инструкция: [cAdvisor.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/cAdvisor.md)
- Реестр заданий: ](../../../TASKS.md)
- Обзор трека: ](../../../README.md)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
