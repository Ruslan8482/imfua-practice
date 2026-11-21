### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/NodeJS.md)

# Node.js REST API CI (`ci-nodejs.yml`)

Источник: [NodeJS.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/NodeJS.md)

## 🎯 Что делает пайплайн

1. Запускает ESLint для `src/` и `tests/`.
2. Запускает Jest-тесты REST API на Node.js 18, 20 и 22.
3. Кэширует `~/.npm` через `actions/cache@v4`.
4. При `push` собирает Docker-образ без публикации.

## 🧰 API

- `GET /health` — проверка живучести.
- `POST /echo` — возвращает полученное тело в JSON.

## 📋 Локальный запуск

```bash
npm install
npm run lint
npm test
npm start
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
