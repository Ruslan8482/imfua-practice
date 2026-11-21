# PHP + MySQL CI (`ci-php-mysql.yml`)

Источник: [PHP.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/PHP.md)

## Что делает пайплайн

1. Проверяет синтаксис PHP через `php -l`.
2. Кэширует Composer через `actions/cache@v4`.
3. Поднимает сервис `mysql:8.0` с healthcheck.
4. Проверяет подключение к MySQL и запускает PHPUnit.

## Локальный запуск

```bash
docker compose up -d
composer install
vendor/bin/phpunit --colors=never
docker compose down
```

## Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.
