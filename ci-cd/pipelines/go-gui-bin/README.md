# Go GUI (Fyne) → GitHub Releases (`cd-go-gui-bin.yml`)

Источник: [CD_Go_GUI.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CD_Go_GUI.md)

## Что делает пайплайн

1. Запускается по тегу `v*` (или вручную).
2. Устанавливает X11/Wayland/GLFW-зависимости на Ubuntu и MSYS2+GCC на Windows.
3. Находит `gcc` динамически, без хардкода пути.
4. Запускает `go mod tidy`, `go vet` и тесты, затем собирает GUI-бинарники для Linux, macOS и Windows.
5. Публикует архивы в GitHub Release.

## Локальный запуск

```bash
sudo apt-get install -y gcc libgl1-mesa-dev xorg-dev
go mod tidy
go test ./...
go run .
```

## Скриншот

![Скриншот запущенного приложения](evidence/app.png)

> Placeholder: положите реальный скриншот окна приложения в `evidence/app.png`.
