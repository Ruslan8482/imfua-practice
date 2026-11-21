# Статический сайт → GitHub Pages (`cd-static-site-pages.yml`)

Источник: [CI_CD_static_site_Deploy.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_static_site_Deploy.md)

## Что делает пайплайн

1. Проверяет HTML через `html-validate`, CSS через `stylelint`, JS через `eslint`.
2. Не требует шага сборки — файлы деплоятся как есть.
3. Использует гейтинг `needs: ci` перед деплоем.
4. Загружает каталог через `actions/upload-pages-artifact@v3` и деплоит через `actions/deploy-pages@v4`.

## Локальный запуск

```bash
npm install
npm run validate
python3 -m http.server 8000
```

## Скриншот

![Скриншот живого сайта](evidence/site.png)

> Placeholder: положите реальный скриншот сайта в `evidence/site.png`.
