# Лабораторная 13 — FULLTEXT-поиск в MySQL

**Оригинал:** [FULLTEXT.md — Полнотекстовый поиск (FULLTEXT) в MySQL. Практическое руководство](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/FULLTEXT.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/FULLTEXT.md`

> ⚠️ **Статус отчёта.** В этой среде нет Docker/MySQL: реальные логи, дампы и
> скриншоты генерируются **при запуске на вашей машине** (инструкция требует WSL).
> Плейсхолдеры `<...>` заменяются реальными значениями вашего MySQL 8.0.

## Цель

Убедиться, что `LIKE '%слово%'` делает полный перебор, создать FULLTEXT-индекс
(перевёрнутый индекс) `ft_articles`, освоить три режима поиска —
`NATURAL LANGUAGE MODE` (с релевантностью), `BOOLEAN MODE` (`+`, `-`, `*`, `"..."`,
`~`, `>`, `<`, `(...)`) и `WITH QUERY EXPANSION`, — а также разобрать ограничения
InnoDB (стоп-слова, `innodb_ft_min_token_size`) и сравнить планы `LIKE` / `FULLTEXT`.

## Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf`: UTF-8 без BOM, LF, `general_log = 1` |
| `01_schema.sql` | `CREATE DATABASE fulltext_practice`, таблица `articles` |
| `02_seed.sql` | 5 статей из инструкции (точные заголовки, тексты, авторы) |
| `03_queries.sql` | Разделы 3–9: `EXPLAIN LIKE`, `CREATE FULLTEXT INDEX`, все режимы поиска, переменные InnoDB |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## Пошаговое выполнение

```bash
cd imfua-practice
make check
bash database/13-fulltext/commands.sh      # контейнер imfua-13-fulltext, БД fulltext_practice
```

Шаги `commands.sh`:

1. Удаляет старый контейнер и volume (без опасного `docker volume prune -a`).
2. Копирует общий `my.cnf` в каталог задания.
3. `docker run --name imfua-13-fulltext -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
   -e MYSQL_INITDB_SKIP_TZINFO=1 -v <volume>:/var/lib/mysql \
   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Ждёт MySQL, проверяет `general_log` и `log_output`.
5. Очищает лог: `docker exec -u mysql imfua-13-fulltext sh -c ': > /var/lib/mysql/general.log'`.
6. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql`.
7. `bash scripts/export-log.sh 13-fulltext` и `bash scripts/dump-db.sh 13-fulltext fulltext_practice`.

Интерактивно: `docker exec -it imfua-13-fulltext mysql --default-character-set=utf8mb4 -uroot -p` (пароль `123`).

## Результаты: EXPLAIN «до/после»

| № | Запрос | До: `type / key / rows / Extra` | После: `type / key / rows / Extra` | Что должно измениться |
|---|--------|----------------------------------|-------------------------------------|------------------------|
| 1 | `EXPLAIN SELECT * FROM articles WHERE body LIKE '%replication%';` **до** индекса | `<type>` / `<key>` / `<rows>` / `<Extra>` (инструкция: `ALL` / `NULL` / `5` / `Using where`) | — | LIKE не использует B-дерево |
| 2 | `CREATE FULLTEXT INDEX ft_articles ON articles(title, body);` → `SHOW INDEX FROM articles` | — | `Index_type = <FULLTEXT>` | Появился перевёрнутый индекс |
| 3 | Тот же `EXPLAIN ... LIKE '%replication%'` **после** FULLTEXT | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (по-прежнему `ALL`) | LIKE остаётся полным перебором |
| 4 | `EXPLAIN SELECT * FROM articles WHERE MATCH(title, body) AGAINST ('replication');` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `fulltext` / `ft_articles` / `1` / `Using where; Ft_hints: sorted`) | Индекс используется |

**Результаты поиска (вписать ids и score):**

| Режим | Запрос из `03_queries.sql` | Найдено `id` | `score` |
|-------|---------------------------|--------------|---------|
| NATURAL LANGUAGE | `AGAINST ('replication')` | `<...>` | `<...>` |
| NATURAL LANGUAGE (явный) | `AGAINST ('replication' IN NATURAL LANGUAGE MODE)` | `<...>` | `<...>` |
| NATURAL LANGUAGE (2 слова) | `AGAINST ('MySQL replication')` | `<...>` | `<...>` |
| BOOLEAN | `'+MySQL -replication'` | `<...>` | — |
| BOOLEAN | `'"query optimization"'` | `<...>` | — |
| BOOLEAN | `'replicat*'` | `<...>` | — |
| BOOLEAN | `'+MySQL +(index* partition*) -MyISAM'` | `<...>` | — |
| WITH QUERY EXPANSION | `'replication' WITH QUERY EXPANSION` | `<...>` | `<...>` |

Переменные InnoDB: `innodb_ft_min_token_size = <...>` (по умолчанию 3),
`innodb_ft_enable_stopword = <...>` (по умолчанию ON),
`innodb_ft_max_token_size = <...>` (по умолчанию 84).

## Места под скриншоты (создаются при запуске)

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-like-explain-before.png` | `EXPLAIN ... LIKE '%replication%'` до индекса |
| `evidence/02-fulltext-index.png` | `SHOW INDEX FROM articles` (`ft_articles`, FULLTEXT) |
| `evidence/03-natural-language.png` | Результат `MATCH ... AGAINST ('replication')` с `score` |
| `evidence/04-boolean-mode.png` | Результаты операторов `+`, `-`, `*`, `"..."`, `~`, `>`, `<` |
| `evidence/05-explain-fulltext.png` | `EXPLAIN ... MATCH ... AGAINST` (`type: fulltext`) |
| `evidence/06-query-expansion.png` | Результат `WITH QUERY EXPANSION` |
| `evidence/07-variables.png` | `SHOW VARIABLES LIKE 'innodb_ft_...'` |
| `evidence/08-log-dump.png` | `head artifacts/my_actions.log` и дамп |

## Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только ваши SQL-действия).

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создаётся при запуске |
| `artifacts/my_actions.log` | Отфильтрованный лог | Создаётся при запуске |
| `artifacts/fulltext_practice-dump.sql` | Дамп 5 статей + индекс `ft_articles` | Создаётся при запуске |
| `database/logs/13-fulltext-actions.log` | Копия лога | Создаётся при запуске |
| `database/dumps/13-fulltext-fulltext_practice-dump.sql` | Копия дампа | Создаётся при запуске |

Реальные логи, дампы и PNG в Git не коммитятся — в репозитории только `.gitkeep`.

## Чек-лист сдачи

- [ ] MySQL 8.0 поднят с общим `my.cnf`; `general_log = ON`.
- [ ] Лог очищен до начала экспериментов.
- [ ] Показано, что `LIKE '%replication%'` даёт `type: ALL` даже после FULLTEXT.
- [ ] Создан `FULLTEXT INDEX ft_articles ON articles(title, body)`.
- [ ] Выполнены поиски во всех трёх режимах: NATURAL LANGUAGE, BOOLEAN, WITH QUERY EXPANSION.
- [ ] Проверены переменные `innodb_ft_min_token_size` и `innodb_ft_enable_stopword`.
- [ ] Таблица EXPLAIN «до/после» заполнена реальными значениями.
- [ ] Скриншоты в `evidence/`, лог/дамп в `artifacts/`, лог без служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.
