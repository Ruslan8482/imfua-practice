# Практика по курсам `rurewa/imfua`

Локальный рабочий репозиторий со всеми практическими заданиями из:

- [Основы проектирования баз данных (Практика)](https://github.com/rurewa/imfua/tree/main/content/Courses/Basics_database_design) — 16 лабораторных;
- [Docker CLI / ImageLibrary](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/README.md) — 24 задания;
- [Dockerfile](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md) — 21 задание;
- [Docker Compose](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/README.md) — 9 проектов;
- [CI/CD в GitHub Actions](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/README.md) — 19 пайплайнов.

Полный реестр с ссылками на оригинальные инструкции: **[TASKS.md](TASKS.md)**.
Архитектура и соглашения: **[ARCHITECTURE.md](ARCHITECTURE.md)**.
Порядок запуска и сдачи: **[docs/workflow.md](docs/workflow.md)**.

## Что сделано

| Раздел | Каталог | Заданий | Содержимое |
|--------|---------|---------|------------|
| Базы данных (MySQL) | `database/NN-*` | 16 | SQL-схемы, данные, запросы, `my.cnf`, команды запуска, шаблоны отчётов |
| Docker CLI | `docker/image-library/NN-*` | 24 | готовые команды, проверки, шаблоны отчётов |
| Dockerfile | `docker/dockerfile/NN-*` | 21 | `Dockerfile`, исходники, `.dockerignore`, команды сборки |
| Docker Compose | `docker/compose/NN-*` | 9 | `compose.yaml`, `.env.example`, команды запуска |
| GitHub Actions | `.github/workflows/*.yml` | 19 | готовые CI/CD-Workflow + проекты в `ci-cd/pipelines/` |

**Итого: 89 заданий.**

## Быстрый старт

```bash
make check                        # статическая проверка всего репозитория
make run-lab LAB=01-lesson-1      # поднять MySQL с general_log
bash scripts/export-log.sh 01-lesson-1
bash scripts/dump-db.sh 01-lesson-1 my_database
```

## Важно

- В среде, где собран репозиторий, нет Docker, MySQL, WSL и компиляторов.
  Поэтому реальные `general.log`, дампы и скриншоты **не сгенерированы**:
  для них созданы директории `artifacts/`, `evidence/`, `database/logs/`, `database/dumps/`
  и шаблоны отчётов. Если ваш преподаватель требует именно файлы лога/дампа —
  выполните задания по инструкции на своей машине, скрипты уже подготовлены.
- В Git **не выполнялись** `git init`, `add`, `commit`, `push` и настройка `remote`.
  Репозиторий готов к ручной инициализации: `make init`.
- Текстовые файлы сохранены в UTF-8 без BOM с переводами строк LF (проверяется `make check`).

## Статус заданий

Все задания имеют статус **«подготовлено, требуется запуск»**: код и инструкции готовы,
реальные следы выполнения (логи/дампы/скриншоты) появляются после запуска на машине с Docker.
Детали — в `TASKS.md` и в `README.md` каждого задания.
