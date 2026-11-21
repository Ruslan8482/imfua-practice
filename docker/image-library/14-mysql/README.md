### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/MySQL.md)

# 14. MySQL

> **Важно:** для реального запуска необходим Docker. В этой среде Docker отсутствует:
> команды ниже — готовые инструкции, а не выполненные действия; значения в разделе
> «Результаты» — плейсхолдеры, которые заполняются после запуска на вашей машине.

## 🧰 Что за образ

Запуск СУБД MySQL 8 с переменными окружения для пароля, базы и пользователя, подключение через mysql CLI.

- **Образ(ы):** `mysql:8`

### Порты

| Порт хоста | Порт контейнера | Назначение |
|---|---|---|
| `3306` | `3306` | MySQL |

### Переменные окружения

| Переменная | Пример/заглушка | Назначение |
|---|---|---|
| `MYSQL_ROOT_PASSWORD` | `CHANGE_ME_ROOT_PASSWORD` | пароль root |
| `MYSQL_DATABASE` | `mydb` | создаваемая база |
| `MYSQL_USER` | `user` | создаваемый пользователь |
| `MYSQL_PASSWORD` | `CHANGE_ME_USER_PASSWORD` | пароль пользователя |

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

### 1. Загрузка образа

```shell
docker pull mysql:8
```

### 2. Запуск в Git-Bash/Linux/WSL/Mac

```shell
docker run -d \
  --name my-mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  mysql:8
```

### 3. Вариант для Windows PowerShell

```shell
docker run -d `
  --name my-mysql `
  -p 3306:3306 `
  -e MYSQL_ROOT_PASSWORD=rootpassword `
  -e MYSQL_DATABASE=mydb `
  -e MYSQL_USER=user `
  -e MYSQL_PASSWORD=password `
  mysql:8
```

### 4. Подключение (пароль: rootpassword)

```shell
docker exec -it my-mysql mysql -u root -p
```

### 5. Проверка работы

```sql
SHOW DATABASES;
SELECT version();
EXIT;
```

### 6. Логи контейнера

```shell
docker logs my-mysql
```

### Очистка контейнера

```shell
docker stop my-mysql || true
docker rm -f my-mysql || true
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

![Скриншот результата — 14-mysql](evidence/14-mysql.png)

<!-- Вставьте реальный скриншот в evidence/ и обновите путь выше. -->

## 🔗 Источник

- Оригинальная инструкция: [MySQL.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/MySQL.md)
- Реестр заданий: [TASKS.md § Docker CLI, п. 14](../../TASKS.md)
- Обзор трека: [docker/README.md](../README.md)

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
