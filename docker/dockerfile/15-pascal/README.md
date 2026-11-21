# 15. Dockerfile. Pascal

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [Pascal.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Pascal.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
15-pascal/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
└── hello.pas
```

## Сборка и запуск

```bash
cd docker/dockerfile/15-pascal
docker build -t imfua-pascal .
docker run --rm imfua-pascal
```

## Проверка

В терминале должна появиться строка `Hello from Pascal in Docker! 🐳`.

## Порты

Порты не используются.



## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-pascal`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
