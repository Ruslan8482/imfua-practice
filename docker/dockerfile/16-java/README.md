# 16. Dockerfile. Java

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [java.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/java.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
16-java/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── pom.xml
└── src/main/java/com/example/Main.java
```

## Сборка и запуск

```bash
cd docker/dockerfile/16-java
docker build -t imfua-java .
docker run --rm imfua-java
```

## Проверка

Ожидаемый вывод: `Hello, World! from Dockerized Java! 🐳`.

## Порты

Порты не используются.

Класс назван `Main` (в источнике — `MyApp`), точка входа в `pom.xml`
указана как `com.example.Main` — это самый простой вариант `Main.java`.

## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-java`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
