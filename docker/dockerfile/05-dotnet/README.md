# 05. Dockerfile. C# (.NET) с публикацией

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [dotNet.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/dotNet.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
05-dotnet/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── MyApp.csproj
└── Program.cs
```

## Сборка и запуск

```bash
cd docker/dockerfile/05-dotnet
docker build -t imfua-dotnet .
docker run -d -p 8081:80 --name imfua-dotnet imfua-dotnet
```

## Проверка

```bash
curl -f http://localhost:8081/
```

Ожидаемый ответ: `Hello from Docker! Привет из Docker!`.

## Порты

Хост `8081` → контейнер `80` (ASP.NET Core).

Примечание: полный код приложения был приведён в источнике, скелет не используется.

## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-dotnet`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
