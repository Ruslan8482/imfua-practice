# Как запускать и сдавать лабораторные

## 1. Подготовка (WSL / Linux; в Windows — Git-Bash только там, где разрешено инструкцией)

```bash
cd imfua-practice
make check                       # убедиться, что всё на месте
make run-lab LAB=01-lesson-1     # поднять MySQL 8.0 с общим my.cnf и general_log
```

## 2. Выполнение

1. Войдите в контейнер: `docker exec -it imfua-01-lesson-1 mysql -uroot -proot`.
2. Очистите лог: `docker exec imfua-01-lesson-1 sh -c ': > /var/lib/mysql/general.log'`.
3. Выполняйте SQL-файлы по порядку номеров (типично `01_schema.sql`, `02_seed.sql`,
   `03_queries.sql`; точный список смотрите в `README.md` задания — например, в лабораторной №2
   файлы называются `01_setup.sql`, `02_schema.sql`, …). Либо вводите команды вручную,
   как требует инструкция — тогда лог содержит именно ваши действия.
4. Сохраните вывод `EXPLAIN`, запросов и проверок в `README.md` задания (скриншоты — в `evidence/`).

## 3. Артефакты

```bash
bash scripts/export-log.sh 01-lesson-1            # artifacts/my_actions.log
bash scripts/dump-db.sh 01-lesson-1 my_database   # artifacts/<db>-dump.sql
```

Лог должен содержать **только ваши действия** (без `Connect`, `Quit`, `SET NAMES`,
загрузки справки и часовых поясов) — фильтрация уже реализована в `export-log.sh`.

## 4. Сдача

- Открыть `README.md` задания, вставить реальные результаты и скриншоты.
- Убедиться, что `my_actions.log` и дамп лежат рядом с отчётом (в `artifacts/`).
- Зафиксировать изменения локально: `git add . && git commit -m "..."`.
- **Push не выполняется** — ответственность за публикацию ссылки преподавателю остаётся за вами.

## Docker и CI/CD

- Docker CLI: `docker/image-library/NN-*/commands.sh` — готовые команды по шагам.
- Dockerfile: `docker/dockerfile/NN-*/Dockerfile` + исходники; сборка из каталога задания.
- Compose: `docker/compose/NN-*/compose.yaml`; запуск `docker compose up -d`.
- GitHub Actions: готовые workflow-файлы в `.github/workflows/`; исходники/тесты — в
  `ci-cd/pipelines/<имя>/`. Workflow срабатывают только после push в ваш репозиторий.
