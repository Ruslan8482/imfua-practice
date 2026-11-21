# Архитектура репозитория практики

Этот репозиторий — результат выполнения практических заданий курсов
`rurewa/imfua`: «Основы проектирования баз данных», Docker CLI / Dockerfile / Docker Compose
и CI/CD в GitHub Actions.

## Принципы

1. **Один каталог = одно задание.** Внутри каталога всё, что нужно для запуска и сдачи.
2. **Воспроизводимость.** Каждая лабораторная поднимается одной командой из `make`,
   конфиги не зависят от хоста (WSL/Git-Bash/Linux).
3. **Отчёт рядом с кодом.** `README.md` внутри задания — это готовый шаблон отчёта
   (цели, команды, результаты, скриншоты, дамп, лог).
4. **Артефакты не коммитятся.** `*.log`, `*.sql` дампов и `evidence/` игнорируются Git,
   чтобы в репозиторий не попадали служебные записи и бинарники. Шаблоны и `.gitkeep` коммитятся.
5. **Единые настройки MySQL.** Общий `database/_shared/my.cnf` с UTF-8, LF и
   `general_log`, копируется в каталог задания при запуске.
6. **Только локально.** Никаких push/remote; репозиторий готов к ручному `git init && git add`.

## Структура

```
imfua-practice/
├── README.md                  # главная навигация + чек-лист сдачи
├── ARCHITECTURE.md            # этот файл
├── TASKS.md                   # полный реестр заданий со ссылками на источники
├── Makefile                   # единая точка входа: make check / run-lab / ...
├── .gitignore
├── scripts/
│   ├── check.sh               # проверка структуры, BOM/CRLF, обязательных файлов
│   ├── run-lab.sh             # поднять MySQL для выбранной лабораторной
│   ├── export-log.sh          # выгрузить и отфильтровать general.log
│   └── dump-db.sh             # сделать дамп без GTID
├── docs/
│   ├── my-cnf.md              # почему UTF-8 без BOM и LF обязательны
│   └── workflow.md            # как запускать и сдавать лабораторные
├── database/
│   ├── README.md
│   ├── _shared/
│   │   ├── my.cnf             # эталонный конфиг логирования
│   │   └── docker-run.sh      # шаблон docker run для всех labs
│   ├── logs/.gitkeep          # сюда кладём my_actions.log (Ignores)
│   ├── dumps/.gitkeep         # сюда кладём дампы (ignored)
│   └── NN-slug/               # 16 лабораторных, см. TASKS.md
│       ├── README.md          # отчёт + скриншоты
│       ├── my.cnf             # копия эталонного (если нужно по инструкции)
│       ├── 01_schema.sql      # имена могут отличаться: 01_setup.sql, 04_*.sql
│       ├── 02_seed.sql        # точный порядок перечислен в README задания
│       ├── 03_queries.sql
│       ├── commands.sh        # docker run / exec / dump / log
│       ├── evidence/.gitkeep  # скриншоты (ignored)
│       └── artifacts/.gitkeep # general.log + dump.sql (ignored)
├── docker/
│   ├── README.md
│   ├── image-library/NN-slug/         # 24 задания Docker CLI (README.md + commands.sh)
│   ├── dockerfile/NN-slug/            # 21 задание Dockerfile (Dockerfile + исходники + README.md)
│   └── compose/NN-slug/               # 9 заданий Docker Compose (compose.yaml + README.md)
├── ci-cd/
│   ├── README.md
│   └── pipelines/name/                # исходники и тесты для пайплайнов
└── .github/workflows/name.yml         # рабочие процессы (19 файлов)
```

## Именование

- Каталоги заданий: `NN-kebab-case`, где `NN` — порядковый номер в реестре `TASKS.md`.
- SQL-файлы нумеруются по этапам: схема → данные → запросы/эксперименты.
- Workflow-файлы называются как тип пайплайна: `ci-python.yml`, `cd-go-ghcr.yml` и т.д.

## Что запускается в этой среде

Здесь нет Docker, MySQL, WSL и компиляторов. Поэтому:
- скрипты и SQL проверены статически (`scripts/check.sh`, `python3`);
- логи, дампы и скриншоты создаются пользователем при запуске на его машине;
- в отчётах явно отмечены места, куда вставляются реальные результаты.

## Ссылки на источники

Все задания скопированы/адаптированы по инструкциям:
- https://github.com/rurewa/imfua/tree/main/content/Courses/Basics_database_design
- https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/README.md
- https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md
- https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/README.md
- https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/README.md
