### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Flask+Python_Mini.md)

# 04. Dockerfile. Flask + Python (мини-проект)

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [Flask+Python_Mini.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Flask+Python_Mini.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
04-flask-python/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── app.py
└── requirements.txt
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/04-flask-python
docker build -t imfua-flask .
docker run -d -p 8082:5000 --name imfua-flask imfua-flask
```

## ✅ Проверка

```bash
curl -f http://localhost:8082/
curl -f http://localhost:8082/health
```

Ожидаемые ответы: приветственная строка и `{"status":"healthy"}`.

## 🧰 Порты

Хост `8082` → контейнер `5000` (Flask).



## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-flask`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
