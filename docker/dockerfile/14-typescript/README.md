# 14. Dockerfile. Приложение на TypeScript

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [TypeScript.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/TypeScript.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
14-typescript/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── package.json
├── tsconfig.json
└── index.ts
```

## Сборка и запуск

```bash
cd docker/dockerfile/14-typescript
docker build -t imfua-typescript .
docker run -it --rm imfua-typescript
```

## Проверка

В выводе должна появиться строка:
`Hello, Developer! Welcome to TypeScript in Docker! 🐳`.

Проверить компиляцию можно и вне контейнера: `npm install && npm run build`.

## Порты

Порты не используются (консольное приложение).

`tsconfig.json` использует `rootDir: "."` и `include: ["index.ts"]`: файл лежит в корне
каталога, как требуется реестром заданий, а компиляция идёт в `dist/index.js`.

## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-typescript`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
