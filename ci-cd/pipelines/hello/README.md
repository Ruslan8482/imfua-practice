### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/hello.md)

# Первый Pipeline (`ci-hello.yml`)

Источник: [hello.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/hello.md)

## 🎯 Что делает пайплайн

1. Срабатывает на `push`, `pull_request` и вручную через `workflow_dispatch`.
2. Разворачивает репозиторий через `actions/checkout@v4`.
3. Запускает `hello.sh` — минимальную программу «Привет, мир!».
4. Запускает `tests/test_hello.sh`, который проверяет вывод скрипта.

## 📋 Локальный запуск

```bash
bash hello.sh
bash tests/test_hello.sh
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`
> после первого успешного запуска на GitHub.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
