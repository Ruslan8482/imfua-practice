### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md)

# 21. PostgreSQL + CloudBeaver

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [README.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
21-postgres-cloudbeaver/
├── Dockerfile          # PostgreSQL + init-скрипт
├── compose.yaml        # БД + веб-интерфейс
├── .dockerignore
├── .env.example
├── init/
│   └── 01_init.sql
├── README.md
└── commands.sh
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/21-postgres-cloudbeaver
cp .env.example .env          # замените POSTGRES_PASSWORD и настройки интерфейса
bash commands.sh up           # = docker compose up -d --build
```

Откройте CloudBeaver, согласитесь с лицензией, создайте соединение `PostgreSQL`: Host=`db`, Port=`5432`, Database=`imfua_demo`, User/Password из `.env`.

## ✅ Проверка

```bash
docker compose ps
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT * FROM demo_items;"'
curl -f http://localhost:8978/
```

## 🧰 Порты

- Хост `5432` → контейнер `5432` (PostgreSQL).
- Хост `8978` → контейнер `8978` (CloudBeaver).

При первом запуске CloudBeaver может предложить принять условия лицензии и задать
пароль администратора — это делается в браузере. Данные соединения сохраняются в volume `cb_data`.


Задание самостоятельное: готового пошагового кода в источнике нет, поэтому конфигурация составлена на основе раздела «Самостоятельно» README источника.

## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-postgres-cloudbeaver`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
