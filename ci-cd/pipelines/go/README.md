# Go CI (`ci-go.yml`)

Источник: [Go.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Go.md)

## Что делает пайплайн

1. Проверяет форматирование `gofmt -l`.
2. Запускает `go vet ./...`.
3. Запускает `go test -v -coverprofile=coverage.out ./...` и загружает отчёт в артефакты.
4. При `push` собирает multi-stage Docker-образ и делает smoke-тест.

## Локальный запуск

```bash
go fmt ./...
go vet ./...
go test -v ./...
```

## Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.
