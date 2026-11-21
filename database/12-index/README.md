# Лабораторная 12 — индексы в MySQL (EXPLAIN до/после)

**Оригинал:** [Index.md — Индексы в MySQL. Практическое руководство (с ведением лога)](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/Index.md`

> ⚠️ **Статус отчёта.** В этой среде нет Docker/MySQL: `general.log`, `my_actions.log`,
> дампы и скриншоты создаются **при запуске на вашей машине** (инструкция требует WSL).
> Заполните `<...>` реальными значениями из `EXPLAIN` и добавьте PNG в `evidence/`.

## Цель

Научиться создавать индексы, читать `EXPLAIN`, сравнивать `type` и `rows` до/после
индекса, видеть, что функция в `WHERE` (`YEAR(order_date)`) ломает индекс, а
переписанный диапазон — работает; разобрать левый префикс составного индекса и
покрывающий индекс (`Using index`).

## Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, `general_log = 1`) |
| `01_schema.sql` | `CREATE DATABASE index_practice`, таблицы `customers`, `orders` (FK создаёт индекс `customer_id`) |
| `02_seed.sql` | 5 клиентов + 6 заказов из инструкции, `SHOW TABLES`, проверки |
| `03_queries.sql` | Эксперименты 1–6 строго по порядку + `EXPLAIN ANALYZE` |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## Пошаговое выполнение

```bash
cd imfua-practice
make check
bash database/12-index/commands.sh        # контейнер imfua-12-index, БД index_practice
```

Что делает `commands.sh`:

1. Удаляет старый контейнер/volume; **не** использует `docker volume prune -a`.
2. Копирует общий `my.cnf` в каталог задания.
3. `docker run --name imfua-12-index -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
   -e MYSQL_INITDB_SKIP_TZINFO=1 -v <volume>:/var/lib/mysql \
   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Проверяет `general_log`, `slow_query_log`, `log_output`; при `OFF` — `SET GLOBAL general_log = 'ON'`.
5. Очищает лог: `docker exec -u mysql imfua-12-index sh -c ': > /var/lib/mysql/general.log'`.
6. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql`.
7. `bash scripts/export-log.sh 12-index` и `bash scripts/dump-db.sh 12-index index_practice`.

Интерактивно (как в инструкции): `docker exec -it imfua-12-index mysql --default-character-set=utf8mb4 -uroot -p` (пароль `123`), затем выполняйте запросы из файлов вручную — так лог содержит именно ваши действия.

## Результаты: EXPLAIN «до/после»

| № / эксперимент | Запрос | До: `type / rows / Extra` | После: `type / rows / Extra` | Ожидаемый эффект |
|-----------------|--------|---------------------------|------------------------------|------------------|
| 2. Без индекса | `EXPLAIN SELECT * FROM orders WHERE amount > 1000;` | `<type>` / `<rows>` / `<Extra>` (инструкция: `ALL` / `6` / `Using where`) | — | Полный перебор |
| 3. `CREATE INDEX idx_amount ON orders(amount);` | тот же `EXPLAIN` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` (ожидается `range` / `4` / `Using where`) | `ALL` → `range`, `key = idx_amount` |
| 4. Функция в WHERE | `EXPLAIN SELECT * FROM orders WHERE YEAR(order_date) = 2026;` | `<type>` / `<rows>` / `<Extra>` (`ALL`) | `<type>` / `<rows>` / `<Extra>` (`ALL` — функция ломает индекс) | Индекс не используется |
| 4. Диапазон | `EXPLAIN SELECT * FROM orders WHERE order_date >= '2026-01-01' AND order_date < '2027-01-01';` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` (ожидается `range`, `key = idx_order_date`) | Функция убрана → индекс работает |
| 5. Составной, 1-й столбец | `EXPLAIN SELECT * FROM orders WHERE status = 'paid';` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` (`idx_status_amount`) | Левый префикс `status` |
| 5. Составной, 2 столбца | `... WHERE status = 'paid' AND amount > 1000;` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` | `(status, amount)` работает |
| 5. Только 2-й столбец | `... WHERE amount > 1000;` **после** `DROP INDEX idx_amount` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` (ожидается `ALL`/`index`, `key = NULL`) | Составной индекс не подходит |
| 6. Покрывающий индекс | `EXPLAIN SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id;` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` (ожидается `index`, `idx_customer_amount`, `Using index`) | Таблица не читается |

> На 6 строках оптимизатор может выбрать `ALL` даже при наличии индекса — это
> нормально: `EXPLAIN` показывает план, а не гарантию. Запишите именно то, что
> вернул ваш MySQL 8.0; плейсхолдеры `<...>` заменяются реальными значениями.

## Места под скриншоты (создаются при запуске)

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-show-index-before.png` | `SHOW INDEX FROM orders` до экспериментов (PRIMARY, customer_id) |
| `evidence/02-explain-before.png` | `EXPLAIN ... WHERE amount > 1000` до `idx_amount` |
| `evidence/03-explain-after.png` | Тот же `EXPLAIN` после `CREATE INDEX idx_amount` |
| `evidence/04-year-function.png` | `EXPLAIN ... YEAR(order_date)` и переписанный диапазон |
| `evidence/05-composite.png` | Три `EXPLAIN` составного индекса + после `DROP INDEX idx_amount` |
| `evidence/06-covering.png` | `EXPLAIN SELECT customer_id, SUM(amount) ...` с `Using index` |
| `evidence/07-explain-analyze.png` | `EXPLAIN ANALYZE ...` |
| `evidence/08-log-dump.png` | `head artifacts/my_actions.log`, `head artifacts/index_practice-dump.sql` |

## Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (отфильтрованные действия) → отчёт.

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создаётся при запуске |
| `artifacts/my_actions.log` | Только ваши `CREATE/INSERT/SELECT/EXPLAIN/...` | Создаётся при запуске |
| `artifacts/index_practice-dump.sql` | Дамп с таблицами и всеми индексами экспериментов | Создаётся при запуске |
| `database/logs/12-index-actions.log` | Копия лога | Создаётся при запуске |
| `database/dumps/12-index-index_practice-dump.sql` | Копия дампа | Создаётся при запуске |

Для «чистого» дампа перед выгрузкой можно удалить `idx_amount`, `idx_order_date`,
`idx_status_amount`, `idx_customer_amount` (блок команд есть в конце `03_queries.sql`).

Логи/дампы/PNG игнорируются Git; в репозитории лежат только `.gitkeep`.

## Чек-лист сдачи

- [ ] Контейнер `imfua-12-index` поднят в WSL, `general_log = ON`.
- [ ] Лог очищен до экспериментов (`-u mysql`).
- [ ] Эксперименты 1–6 выполнены в порядке из `03_queries.sql`.
- [ ] Таблица «до/после» заполнена реальными `type`, `rows`, `Extra`.
- [ ] Показано, что `YEAR()` даёт `ALL`, а диапазон — `range`.
- [ ] Показаны левый префикс составного индекса и `Using index`.
- [ ] Скриншоты в `evidence/`, лог и дамп в `artifacts/`.
- [ ] `my_actions.log` не содержит служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.
