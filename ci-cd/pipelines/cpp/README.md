### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/cpp.md)

# C++ CI (`ci-cpp.yml`)

Источник: [cpp.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/cpp.md)

## 🎯 Что делает пайплайн

1. Устанавливает `cmake`, `g++` и `clang-format`.
2. Конфигурирует и собирает проект через CMake.
3. Проверяет форматирование C++ через `clang-format --dry-run --Werror`.
4. Запускает тесты через CTest и загружает бинарник в артефакты.

## 📋 Локальный запуск

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
