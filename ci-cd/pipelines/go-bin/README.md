### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Go_bin.md)

# Go CLI → GitHub Releases (`cd-go-bin.yml`)

Источник: [Go_bin.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Go_bin.md)

## 🎯 Что делает пайплайн

1. Запускается по тегу `v*` (или вручную).
2. Проверяет `gofmt`, `go vet` и тесты.
3. Кросс-компилирует бинарник для Linux (amd64/arm64), macOS (amd64/arm64) и Windows (amd64) с `CGO_ENABLED=0`.
4. Внедряет версию через `-ldflags "-X main.version=..."`.
5. Публикует архивы в GitHub Release через `softprops/action-gh-release@v2`.

## 📋 Локальный запуск

```bash
go test ./...
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o go-bin .
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** и страницы Release.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
