FROM php:8.2-cli-alpine

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN docker-php-ext-install mysqli

WORKDIR /app

COPY composer.json composer.lock* ./
RUN if [ -f composer.lock ]; then composer install --no-dev --no-interaction --no-progress; else composer install --no-dev --no-interaction --no-progress; fi

COPY src ./src
COPY tests ./tests
COPY phpunit.xml ./

CMD ["php", "src/index.php"]
