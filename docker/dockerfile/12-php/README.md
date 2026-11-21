### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/php.md)

# 12. Dockerfile. Приложение на PHP

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [php.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/php.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
12-php/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
└── index.php
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/12-php
docker build -t imfua-php .
docker run -d -p 8081:80 --name imfua-php imfua-php
```

## ✅ Проверка

```bash
curl -f http://localhost:8081/
```

Откройте <http://localhost:8081>: должна отобразиться страница с версией PHP
и списком расширений (включая `pdo_mysql` и `mysqli`).

## 🧰 Порты

Хост `8081` → контейнер `80` (Apache + PHP).



## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-php`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
