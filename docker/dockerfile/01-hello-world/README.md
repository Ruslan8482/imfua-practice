# 01. Dockerfile. Hello-world

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [hello-world.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/hello-world.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
01-hello-world/
├── Dockerfile
├── .dockerignore
├── README.md
└── commands.sh
```

## Сборка и запуск

```bash
cd docker/dockerfile/01-hello-world
docker build -t imfua-hello-world .
docker run --rm imfua-hello-world
```

Или одной командой:

```bash
bash commands.sh
```

## Проверка

В терминале должна появиться строка `Привет, Docker! 🐳`.

## Порты

Порты не используются: контейнер завершается после вывода строки.



## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-hello-world`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
