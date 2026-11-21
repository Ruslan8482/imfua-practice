# Практика по курсам `rurewa/imfua`

### [Реестр заданий](TASKS.md) · [Архитектура](ARCHITECTURE.md) · [Порядок запуска](docs/workflow.md)

Локальный рабочий репозиторий со всеми практическими заданиями из:

- [Основы проектирования баз данных (Практика)](https://github.com/rurewa/imfua/tree/main/content/Courses/Basics_database_design) — 16 лабораторных;
- [Docker CLI / ImageLibrary](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/README.md) — 24 задания;
- [Dockerfile](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md) — 21 задание;
- [Docker Compose](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/README.md) — 9 проектов;
- [CI/CD в GitHub Actions](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/README.md) — 19 пайплайнов.

Репозиторий опубликован: **https://github.com/Ruslan8482/imfua-practice**

Полный реестр с ссылками на оригинальные инструкции: **[TASKS.md](TASKS.md)**.
Архитектура и соглашения: **[ARCHITECTURE.md](ARCHITECTURE.md)**.
Порядок запуска и сдачи: **[docs/workflow.md](docs/workflow.md)**.

## Навигация

- [Реестр заданий](TASKS.md)
- [Архитектура репозитория](ARCHITECTURE.md)
- [Порядок запуска и сдачи](docs/workflow.md)
- [Почему UTF-8 без BOM и LF](docs/my-cnf.md)

### Теория

- [Основы проектирования баз данных](https://github.com/rurewa/imfua/tree/main/content/Courses/Basics_database_design)
- [Docker — документация и практические задачи](https://github.com/rurewa/imfua/blob/main/content/Docker/README.md)
- [CI/CD в GitHub Actions](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/README.md)

### Практика

- [Базы данных (MySQL)](database/README.md) — 16 лабораторных;
- [Docker CLI / ImageLibrary](docker/README.md) — 24 задания;
- [Dockerfile](docker/README.md) — 21 задание;
- [Docker Compose](docker/README.md) — 9 проектов;
- [CI/CD в GitHub Actions](ci-cd/README.md) — 19 пайплайнов.

## 🎯 Цель

Собрать в одном репозитории все практические задания курсов `rurewa/imfua`,
подготовить воспроизводимые конфиги и скрипты, **реально выполнить лабораторные по БД**
и сохранить логи/дампы как доказательство выполненной работы.

## 📚 Что сделано

| Раздел | Каталог | Заданий | Содержимое | Статус |
|--------|---------|---------|------------|--------|
| Базы данных (MySQL) | `database/NN-*` | 16 | SQL-схемы, данные, запросы, `my.cnf`, реальные логи, дампы, отчёты | ✅ выполнено локально на MariaDB 11.4.14 |
| Docker CLI | `docker/image-library/NN-*` | 24 | готовые команды, проверки, отчёты | подготовлено, требуется Docker |
| Dockerfile | `docker/dockerfile/NN-*` | 21 | `Dockerfile`, исходники, `.dockerignore`, команды сборки | подготовлено, требуется Docker |
| Docker Compose | `docker/compose/NN-*` | 9 | `compose.yaml`, `.env.example`, команды запуска | подготовлено, требуется Docker |
| GitHub Actions | `.github/workflows/*.yml` | 19 | CI/CD-workflow + проекты в `ci-cd/pipelines/` | ✅ запущены в GitHub Actions |

**Итого: 89 заданий.**

## 🧰 Быстрый старт

```bash
make check                            # статическая проверка всего репозитория
bash scripts/start-local-mariadb.sh   # поднять локальный MariaDB (без Docker)
bash scripts/collect-evidence.sh      # выполнить 16 лабораторных и собрать логи/дампы
bash scripts/export-log.sh 01-lesson-1
bash scripts/dump-db.sh 01-lesson-1 sales
```

## ✅ Доказательства выполнения

Все 16 лабораторных по БД реально выполнены локальным MariaDB 11.4.14
(совместимым с MySQL 8.0 дистрибутивом) — Docker в среде сборки недоступен.
В каждом `database/NN-*/artifacts/` лежат:

| Файл | Что это |
|------|---------|
| `general.log` | настоящий лог сервера за время выполнения лабораторной |
| `my_actions.log` | отфильтрованный лог действий пользователя |
| `execution-output.txt` | полный вывод SQL-скриптов с кодами возврата |
| `RESULT.txt` | краткий итог: файлы, ошибки, размеры, дата |
| `*-dump.sql` | дампы созданных баз (включая дампы до `DROP`/восстановления) |

Скрипты воспроизведения: [`scripts/start-local-mariadb.sh`](scripts/start-local-mariadb.sh),
[`scripts/collect-evidence.sh`](scripts/collect-evidence.sh).
Workflow'ы CI/CD запускались в GitHub Actions при push; статус виден во вкладке
[Actions](https://github.com/Ruslan8482/imfua-practice/actions) и в сводке
[ci-cd/GITHUB-ACTIONS.md](ci-cd/GITHUB-ACTIONS.md).
GitHub Pages включён: https://ruslan8482.github.io/imfua-practice/.

## ⚠️ Важно

- Скриншоты в `evidence/` не создавались: в среде нет GUI. Все текстовые доказательства
  (логи, выводы запросов, дампы) сохранены в `artifacts/`.
- Задания Docker/Dockerfile/Compose подготовлены и проверены статически, но не запускались:
  в среде сборки нет Docker. Их можно выполнить на машине с Docker по `commands.sh`.
- Текстовые файлы сохранены в UTF-8 без BOM с переводами строк LF (проверяется `make check`).
- Токен доступа, использованный для push, нигде не сохранён.

## 📊 Статус заданий

- **БД (16/16)** — реально выполнены, логи и дампы приложены к каждому отчёту.
- **CI/CD (19)** — workflow запущены в GitHub Actions.
- **Docker (24 + 21 + 9)** — подготовлено, требуется запуск на машине с Docker.

Детали — в `TASKS.md` и в `README.md` каждого задания.

## 🔗 Полезные ссылки

- [Исходный репозиторий заданий](https://github.com/rurewa/imfua)
- [Основы проектирования баз данных](https://github.com/rurewa/imfua/tree/main/content/Courses/Basics_database_design)
- [Docker CLI / ImageLibrary](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/README.md)
- [Dockerfile](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md)
- [Docker Compose](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/README.md)
- [CI/CD в GitHub Actions](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/README.md)
- [Реестр заданий](TASKS.md), [архитектура](ARCHITECTURE.md), [workflow](docs/workflow.md), [my.cnf](docs/my-cnf.md)

## 📌 Итог

89 заданий структурированы по пяти разделам. Лабораторные по БД выполнены на реальном
MariaDB с сохранением логов и дампов как доказательства; CI/CD workflow запущены в GitHub.
Docker-задания готовы к запуску на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
