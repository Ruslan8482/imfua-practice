### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/ArduinoManager.md)

# Arduino Manager → GitHub Releases (`cd-arduino-manager-bin.yml`)

Источник: [ArduinoManager.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/ArduinoManager.md)

## 🎯 Что делает пайплайн

1. Запускается по тегу `v*` (или вручную).
2. Тестирует разбор строк `arduino-cli board list`.
3. Собирает Fyne-GUI под Linux, macOS и Windows; на Windows поднимает MSYS2 и динамически находит GCC.
4. Публикует архивы в GitHub Release через `softprops/action-gh-release@v2`.

## 📋 Локальный запуск

```bash
go mod tidy
go test ./...
go run .
```

## 📸 Скриншот

![Скриншот окна Arduino Manager](evidence/app.png)

> Placeholder: положите реальный скриншот окна приложения в `evidence/app.png`.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
