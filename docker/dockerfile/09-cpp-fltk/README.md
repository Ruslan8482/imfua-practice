# 09. Dockerfile. Оконное приложение C++/FLTK

## Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## Источник

- Оригинал: [cpp_fltk.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cpp_fltk.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## Структура каталога

```text
09-cpp-fltk/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── CMakeLists.txt
└── main.cpp
```

## Сборка и запуск

```bash
cd docker/dockerfile/09-cpp-fltk
docker build -t imfua-fltk .
```

Linux / WSL 2:

```bash
xhost +local:docker
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  imfua-fltk
```

Windows 10 (build 22000+) / 11 с WSLg в PowerShell:

```powershell
docker run -it --rm `
  -v /run/desktop/mnt/host/wslg/.X11-unix:/tmp/.X11-unix `
  -v /run/desktop/mnt/host/wslg:/mnt/wslg `
  -e DISPLAY=:0 `
  -e WAYLAND_DISPLAY=wayland-0 `
  -e XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir `
  imfua-fltk
```

## Проверка

Должно появиться окно 300x180 с кнопкой `Нажми меня!`. Если окно не открылось,
проверьте переменную `DISPLAY` и права `xhost +local:docker`.

## Порты

Порты не используются; необходим X11-сокет хоста (`/tmp/.X11-unix`).

Полный код FLTK из источника присутствует в каталоге, скелет не использовался.

## Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-fltk`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.
