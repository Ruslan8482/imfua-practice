### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cpp.md)

# 06. Dockerfile. Консольное приложение на C++

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [cpp.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cpp.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
06-cpp/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
└── hello.cpp
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/06-cpp
docker build -t imfua-cpp .
docker run --rm imfua-cpp
```

## ✅ Проверка

```bash
docker run --rm imfua-cpp
docker run -it --rm --entrypoint sh imfua-cpp
```

Ожидаемый вывод: `Hello, Docker! from C++`.

## 🧰 Порты

Порты не используются.



## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-cpp`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
