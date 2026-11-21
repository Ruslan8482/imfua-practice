### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Python.md)

# 03. Dockerfile. Простое приложение на Python

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [Python.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Python.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
03-python/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── app.py
└── requirements.txt
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/03-python
docker build -t imfua-python .
docker run --rm imfua-python
```

## ✅ Проверка

В выводе должна появиться строка `Hello from Python in Docker! 🐍`.

## 🧰 Порты

Порты не используются.



## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-python`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
