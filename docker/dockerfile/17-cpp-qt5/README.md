# 17. Dockerfile. Qt5 / C++

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [cppQt5.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cppQt5.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
17-cpp-qt5/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── CMakeLists.txt
├── main.cpp
└── run.sh
```

## Сборка и запуск

```bash
cd docker/dockerfile/17-cpp-qt5
docker build -t imfua-qt5 .
chmod +x run.sh
./run.sh
```

Эквивалентный запуск без `run.sh`:

```bash
xhost +local:docker
docker run --rm -it -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw imfua-qt5
```

## Проверка

Должно появиться окно `400x200` с надписью `Привет из Docker + Qt!`.
Если окно не показывается, проверьте `DISPLAY`, `xhost +local:docker`
и логи: `docker logs <container_id>`.

## Порты

Порты не используются; нужен X11-сокет хоста. Задание рекомендуется выполнять в WSL/Ubuntu.

Полный код из источника (включая `run.sh`) присутствует в каталоге; скелет не использовался.
Из Dockerfile убран notebook-пакет `default-jdk`, который не нужен для сборки Qt Widgets.

## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-qt5`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
