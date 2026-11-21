# 02. Dockerfile. Статический сайт на Nginx

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [my-site.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/my-site.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
02-nginx-static-site/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
└── site/
    └── index.html
```

## Сборка и запуск

```bash
cd docker/dockerfile/02-nginx-static-site
docker build -t imfua-nginx-site .
docker run -d -p 8081:80 --name imfua-nginx-site imfua-nginx-site
```

Для разработки можно смонтировать папку `site/` и править HTML без пересборки:

```bash
docker run -d -p 8081:80 --name imfua-nginx-site-dev -v "$(pwd)/site":/usr/share/nginx/html nginx:alpine
```

## Проверка

```bash
curl -f http://localhost:8081/
```

или открыть <http://localhost:8081> в браузере.

## Порты

Хост `8081` → контейнер `80` (Nginx).



## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-nginx-site`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
