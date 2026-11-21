#!/usr/bin/env bash
# 15-mongodb: команды задания (pull -> run -> проверка -> cleanup).
# ВНИМАНИЕ: это dry-run. Скрипт только печатает команды и НЕ запускает Docker.
# Для реального выполнения скопируйте нужные строки в терминал на машине с Docker.
# В текущей среде Docker отсутствует.
set -euo pipefail

step() { printf '\n== %s ==\n' "$1"; }

step "0. Проверка Docker и чистого листа"
cat <<'CMD'
docker version
docker ps -a
CMD

step "1. Загрузка образа"
cat <<'CMD'
docker pull mongo:latest
CMD

step "2. Запуск в Git-Bash/Linux/WSL/Mac"
cat <<'CMD'
docker run -d \
  --name my-mongo \
  -p 27017:27017 \
  mongo:latest
CMD

step "3. Вариант для Windows PowerShell"
cat <<'CMD'
docker run -d `
  --name my-mongo `
  -p 27017:27017 `
  mongo:latest
CMD

step "4. Подключение через mongosh"
cat <<'CMD'
docker exec -it my-mongo mongosh
CMD

step "5. Проверка работы: операции с документами"
cat <<'CMD'
show dbs
use myapp
db.users.insertOne({ name: "Иван", age: 30, city: "Москва" })
db.users.find()
db.users.find({ age: { $gt: 25 } })
db.users.updateOne({ name: "Иван" }, { $set: { age: 31 } })
db.users.deleteOne({ name: "Иван" })
show collections
exit
CMD

step "Очистка"
cat <<'CMD'
docker stop my-mongo || true
docker rm -f my-mongo || true
CMD

printf '\nВсе команды выведены выше; ни одна не была выполнена.\n'
