### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_Go.md)

# Go CLI → GHCR (`cd-go-ghcr.yml`)

Источник: [CI_CD_Go.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_Go.md)

## 🎯 Что делает пайплайн

1. Проверяет `gofmt`, `go vet` и тесты.
2. Логинится в GHCR через `docker/login-action@v3` только при `push`.
3. Публикует multi-stage Docker-образ через `docker/build-push-action@v6`.
4. Для pull request выполняется только сборка образа без push.

## 📋 Локальный запуск

```bash
go test ./...
docker build -t go-ghcr .
docker run --rm go-ghcr
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** и страницы пакета GHCR.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
