### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/hello_java.md)

# Hello Java CI (`ci-java.yml`)

Источник: [hello_java.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/hello_java.md)

## 🎯 Что делает пайплайн

1. Устанавливает JDK 17 (Temurin) через `actions/setup-java@v4` с кэшем Maven.
2. Собирает проект и запускает JUnit-тесты командой `mvn -B verify`.
3. Загружает готовый JAR-файл в артефакты workflow.

## 📋 Локальный запуск

```bash
mvn -B verify
java -jar target/hello-java-1.0.0.jar
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
