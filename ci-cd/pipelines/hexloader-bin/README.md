# Hex Loader → GitHub Releases (`cd-hexloader-bin.yml`)

Источник: [HexLoader.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/HexLoader.md)

## Что делает пайплайн

1. Запускается по тегу `v*` (или вручную).
2. Проверяет логику разбора Intel HEX тестами и `go vet`.
3. Собирает Fyne-GUI под Linux, macOS и Windows с CGO и MSYS2 на Windows.
4. Динамически ищет `gcc.exe` в MSYS2.
5. Публикует бинарники в GitHub Release.

## Локальный запуск

```bash
go mod tidy
go test ./...
go run .
```

## Скриншот

![Скриншот окна Hex Loader](evidence/app.png)

> Placeholder: положите реальный скриншот окна приложения в `evidence/app.png`.
