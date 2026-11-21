### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_Deploy_GitHub_Pages.md)

# React SPA → GitHub Pages (`cd-github-pages.yml`)

Источник: [CI_Deploy_GitHub_Pages.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_Deploy_GitHub_Pages.md)

## 🎯 Что делает пайплайн

1. Устанавливает зависимости и кэширует npm через `actions/cache@v4`.
2. Выполняет `tsc --noEmit` и тесты Vitest (jsdom).
3. Собирает Vite-проект в `dist/`.
4. Деплоит `dist/` через `actions/upload-pages-artifact@v3` и `actions/deploy-pages@v4` с окружением `github-pages`.

## 📋 Локальный запуск

```bash
npm install
npm run typecheck
npm test
npm run build
```

## 📸 Скриншот

![Скриншот живого SPA](evidence/site.png)

> Placeholder: положите реальный скриншот сайта в `evidence/site.png`.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
