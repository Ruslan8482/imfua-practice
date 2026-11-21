#!/usr/bin/env bash
# Шаблон команды из инструкций: запуск MySQL 8 с логом и UTF-8.
# Скопируйте в каталог задания и замените NAME/PASS при необходимости.
docker rm -f my-mysql >/dev/null 2>&1 || true
docker run -d --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -p 3306:3306 \
  -v "$(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro" \
  mysql:8.0

docker exec my-mysql sh -c ': > /var/lib/mysql/general.log'
docker exec -it my-mysql mysql -uroot -proot
