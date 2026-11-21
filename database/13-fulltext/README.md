### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/FULLTEXT.md)

# Лабораторная 13 — FULLTEXT-поиск в MySQL

**Оригинал:** [FULLTEXT.md — Полнотекстовый поиск (FULLTEXT) в MySQL. Практическое руководство](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/FULLTEXT.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/FULLTEXT.md`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

Убедиться, что `LIKE '%слово%'` делает полный перебор, создать FULLTEXT-индекс
(перевёрнутый индекс) `ft_articles`, освоить три режима поиска —
`NATURAL LANGUAGE MODE` (с релевантностью), `BOOLEAN MODE` (`+`, `-`, `*`, `"..."`,
`~`, `>`, `<`, `(...)`) и `WITH QUERY EXPANSION`, — а также разобрать ограничения
InnoDB (стоп-слова, `innodb_ft_min_token_size`) и сравнить планы `LIKE` / `FULLTEXT`.

## 🧰 Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf`: UTF-8 без BOM, LF, `general_log = 1` |
| `01_schema.sql` | `CREATE DATABASE fulltext_practice`, таблица `articles` |
| `02_seed.sql` | 5 статей из инструкции (точные заголовки, тексты, авторы) |
| `03_queries.sql` | Разделы 3–9: `EXPLAIN LIKE`, `CREATE FULLTEXT INDEX`, все режимы поиска, переменные InnoDB |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## 📋 Пошаговое выполнение

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

## 📊 Результаты: EXPLAIN «до/после»

**СУБД:** MariaDB 11.4.14 (`Version: 11.4.14-MariaDB-log` — первая строка
`artifacts/general.log` и `artifacts/my_actions.log`). Все значения ниже взяты из
табличных строк `EXPLAIN` в `artifacts/execution-output.txt` (блок `03_queries.sql`).

| № | Запрос | До: `type / key / rows / Extra` | После: `type / key / rows / Extra` | Что изменилось |
|---|--------|----------------------------------|-------------------------------------|------------------------|
| 1 | `EXPLAIN SELECT * FROM articles WHERE body LIKE '%replication%';` **до** индекса | `ALL` / `NULL` / `5` / `Using where` | — | LIKE не использует B-дерево |
| 2 | `CREATE FULLTEXT INDEX ft_articles ON articles(title, body);` → `SHOW INDEX FROM articles` | — | `Index_type = FULLTEXT` (`ft_articles`, столбцы `title` и `body`) | Появился перевёрнутый индекс |
| 3 | Тот же `EXPLAIN ... LIKE '%replication%'` **после** FULLTEXT | `ALL` / `NULL` / `5` / `Using where` | `ALL` / `NULL` / `5` / `Using where` | LIKE остаётся полным перебором |
| 4 | `EXPLAIN SELECT * FROM articles WHERE MATCH(title, body) AGAINST ('replication');` | не выведено (`EXPLAIN MATCH` выполнялся только после создания индекса) | `fulltext` / `ft_articles` / `1` / `Using where` | Индекс используется; `Ft_hints: sorted` в выводе отсутствует |

**Результаты поиска (ids и score из `artifacts/execution-output.txt`):**

| Режим | Запрос из `03_queries.sql` | Найдено `id` | `score` |
|-------|---------------------------|--------------|---------|
| NATURAL LANGUAGE | `AGAINST ('replication')` | `2` | `1.4656771421432495` |
| NATURAL LANGUAGE (явный) | `AGAINST ('replication' IN NATURAL LANGUAGE MODE)` | `2` | `1.4656771421432495` |
| NATURAL LANGUAGE (2 слова) | `AGAINST ('MySQL replication')` | `2`, `1`, `3`, `4`, `5` | `1.4656771421432495`, `0.000000003771856604828372`, `0.000000001885928302414186`, `0.000000001885928302414186`, `0.000000001885928302414186` |
| BOOLEAN | `'+MySQL -replication'` | `1`, `3`, `4`, `5` | — |
| BOOLEAN | `'"query optimization"'` | `3` | — |
| BOOLEAN | `'replicat*'` | `2` | — |
| BOOLEAN | `'+MySQL +(index* partition*) -MyISAM'` | `1`, `3` | — |
| BOOLEAN (с сортировкой) | `'+MySQL ~performance >FULLTEXT'` | `1`, `2`, `3`, `4`, `5` | `1` для каждого |
| WITH QUERY EXPANSION | `'replication' WITH QUERY EXPANSION` | `2`, `5`, `1`, `4`, `3` | `6.577624797821045`, `0.21696466207504272`, `0.07739152759313583`, `0.028174657374620438`, `0.01878310553729534` |

Переменные InnoDB (фактические значения из вывода): `innodb_ft_min_token_size = 3`,
`innodb_ft_enable_stopword = ON`, `innodb_ft_max_token_size = 84`.

## 📸 Места под скриншоты (не создавались — нет GUI)

Файлы `evidence/*.png` не создавались; таблица ниже сохраняет места, где они
предусмотрены инструкцией.

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

## 📎 Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только ваши SQL-действия).

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создан |
| `artifacts/my_actions.log` | Отфильтрованный лог | Создан |
| `artifacts/execution-output.txt` | Вывод SQL, включая таблицы `EXPLAIN` | Создан |
| `artifacts/RESULT.txt` | Сводка: коды возврата 0, ошибок 0 | Создан |
| `artifacts/fulltext_practice-dump.sql` | Дамп 5 статей + индекс `ft_articles` | Создан |
| `database/logs/13-fulltext-actions.log` | Копия лога | Не создавалась (каталога `database/logs` нет) |
| `database/dumps/13-fulltext-fulltext_practice-dump.sql` | Копия дампа | Не создавалась (каталога `database/dumps` нет) |

Логи и дамп в `artifacts/` созданы при локальном запуске; PNG в `evidence/` не создавались.

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general.log; первая строка фиксирует
  `Version: 11.4.14-MariaDB-log` (MariaDB 11.4.14).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованные действия пользователя
  (70 строк по `RESULT.txt`).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод SQL: планы
  `LIKE`/`FULLTEXT`, результаты поиска и переменные InnoDB.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — 3 SQL-файла, коды возврата 0, ошибок 0.
- [artifacts/fulltext_practice-dump.sql](artifacts/fulltext_practice-dump.sql) — дамп базы
  `fulltext_practice` (2840 байт).
- `artifacts/.gitkeep` — служебный файл каталога.

> Ниже — исходные критерии сдачи. Пункты про Docker/WSL и скриншоты не применимы:
> лабораторная выполнялась локально на MariaDB 11.4.14, GUI отсутствует.

## ✅ Чек-лист сдачи

- [ ] MySQL 8.0 поднят с общим `my.cnf`; `general_log = ON`.
- [ ] Лог очищен до начала экспериментов.
- [ ] Показано, что `LIKE '%replication%'` даёт `type: ALL` даже после FULLTEXT.
- [ ] Создан `FULLTEXT INDEX ft_articles ON articles(title, body)`.
- [ ] Выполнены поиски во всех трёх режимах: NATURAL LANGUAGE, BOOLEAN, WITH QUERY EXPANSION.
- [ ] Проверены переменные `innodb_ft_min_token_size` и `innodb_ft_enable_stopword`.
- [ ] Таблица EXPLAIN «до/после» заполнена реальными значениями.
- [ ] Скриншоты в `evidence/`, лог/дамп в `artifacts/`, лог без служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
