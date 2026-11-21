### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index.md)

# Лабораторная 12 — индексы в MySQL (EXPLAIN до/после)

**Оригинал:** [Index.md — Индексы в MySQL. Практическое руководство (с ведением лога)](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/Index.md`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

> ℹ️ **Адаптация синтаксиса под MariaDB.** В `03_queries.sql` вместо `EXPLAIN ANALYZE SELECT ...`
> использован отдельный оператор `ANALYZE SELECT ...` (в выводе есть столбцы `r_rows`, `filtered`,
> `r_filtered`). Инструкция MySQL 8.0.18+ здесь неприменима напрямую.

## 🎯 Цель

Научиться создавать индексы, читать `EXPLAIN`, сравнивать `type` и `rows` до/после
индекса, видеть, что функция в `WHERE` (`YEAR(order_date)`) ломает индекс, а
переписанный диапазон — работает; разобрать левый префикс составного индекса и
покрывающий индекс (`Using index`).

## 🧰 Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, `general_log = 1`) |
| `01_schema.sql` | `CREATE DATABASE index_practice`, таблицы `customers`, `orders` (FK создаёт индекс `customer_id`) |
| `02_seed.sql` | 5 клиентов + 6 заказов из инструкции, `SHOW TABLES`, проверки |
| `03_queries.sql` | Эксперименты 1–6 строго по порядку + `EXPLAIN ANALYZE` |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## 📋 Пошаговое выполнение

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

## 📊 Результаты: EXPLAIN «до/после»

**СУБД:** MariaDB 11.4.14 (`Version: 11.4.14-MariaDB-log` — первая строка
`artifacts/general.log` и `artifacts/my_actions.log`). Все значения ниже взяты из
табличных строк `EXPLAIN` в `artifacts/execution-output.txt` (блок `03_queries.sql`).

| № / эксперимент | Запрос | До: `type / key / rows / Extra` | После: `type / key / rows / Extra` | Ожидаемый эффект |
|-----------------|--------|---------------------------|------------------------------|------------------|
| 2. Без индекса | `EXPLAIN SELECT * FROM orders WHERE amount > 1000;` | `ALL` / `NULL` / `6` / `Using where` | — | Полный перебор (подтверждено) |
| 3. `CREATE INDEX idx_amount ON orders(amount);` | тот же `EXPLAIN` | `ALL` / `NULL` / `6` / `Using where` | `range` / `idx_amount` / `4` / `Using index condition` | `ALL` → `range`, `key = idx_amount` |
| 4. Функция в WHERE | `EXPLAIN SELECT * FROM orders WHERE YEAR(order_date) = 2026;` | `ALL` / `NULL` / `6` / `Using where` | не выведено: повторного `EXPLAIN` с `YEAR()` после `CREATE INDEX idx_order_date` в выводе нет | Индекс не используется |
| 4. Диапазон | `EXPLAIN SELECT * FROM orders WHERE order_date >= '2026-01-01' AND order_date < '2027-01-01';` | не выведено (запрос выполнялся только после создания `idx_order_date`) | `range` / `idx_order_date` / `6` / `Using index condition` | Функция убрана → индекс работает |
| 5. Составной, 1-й столбец | `EXPLAIN SELECT * FROM orders WHERE status = 'paid';` | не выведено (отдельного `EXPLAIN` до `idx_status_amount` нет) | `ref` / `idx_status_amount` / `3` / `Using index condition` | Левый префикс `status` |
| 5. Составной, 2 столбца | `... WHERE status = 'paid' AND amount > 1000;` | не выведено | `range` / `idx_status_amount` (possible_keys: `idx_amount,idx_status_amount`) / `3` / `Using index condition` | `(status, amount)` работает |
| 5. Только 2-й столбец | `... WHERE amount > 1000;` **после** `DROP INDEX idx_amount` | с `idx_amount`: `range` / `idx_amount` / `4` / `Using index condition` | после `DROP INDEX idx_amount`: `ALL` / `NULL` / `6` / `Using where` | Составной индекс не подходит |
| 6. Покрывающий индекс | `EXPLAIN SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id;` | не выведено (`EXPLAIN` выполнен после `CREATE INDEX idx_customer_amount`) | `index` / `idx_customer_amount` / `6` / `Using index` (possible_keys = `NULL`) | Таблица не читается |

> Фактический `Extra` для `range` — `Using index condition`, а не ожидаемый в инструкции
> `Using where`. Результат `ANALYZE SELECT * FROM orders WHERE amount > 1000;`
> (аналог `EXPLAIN ANALYZE` для MariaDB): `range` / `idx_amount` / `rows=4` /
> `r_rows=4.00` / `filtered=100.00` / `r_filtered=100.00` / `Using index condition`.
> План показывает реально выбранный доступ, а не гарантию использования индекса.

## 📸 Места под скриншоты (не создавались — нет GUI)

Файлы `evidence/*.png` не создавались; таблица ниже сохраняет места, где они
предусмотрены инструкцией.

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

## 📎 Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (отфильтрованные действия) → отчёт.

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создан |
| `artifacts/my_actions.log` | Только ваши `CREATE/INSERT/SELECT/EXPLAIN/...` | Создан |
| `artifacts/execution-output.txt` | Вывод SQL, включая таблицы `EXPLAIN` | Создан |
| `artifacts/RESULT.txt` | Сводка: коды возврата 0, ошибок 0 | Создан |
| `artifacts/index_practice-dump.sql` | Дамп с таблицами и всеми индексами экспериментов | Создан |
| `database/logs/12-index-actions.log` | Копия лога | Не создавалась (каталога `database/logs` нет) |
| `database/dumps/12-index-index_practice-dump.sql` | Копия дампа | Не создавалась (каталога `database/dumps` нет) |

Для «чистого» дампа перед выгрузкой можно удалить `idx_amount`, `idx_order_date`,
`idx_status_amount`, `idx_customer_amount` (блок команд есть в конце `03_queries.sql`).

Логи и дамп в `artifacts/` созданы при локальном запуске; PNG в `evidence/` не создавались.

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general.log; первая строка фиксирует
  `Version: 11.4.14-MariaDB-log` (MariaDB 11.4.14).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованные действия пользователя
  (65 строк по `RESULT.txt`).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод SQL, включая
  все таблицы `EXPLAIN` и `ANALYZE`.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — 3 SQL-файла, коды возврата 0, ошибок 0.
- [artifacts/index_practice-dump.sql](artifacts/index_practice-dump.sql) — дамп базы `index_practice`
  (3689 байт).
- `artifacts/.gitkeep` — служебный файл каталога.

> Ниже — исходные критерии сдачи. Пункты про Docker/WSL и скриншоты не применимы:
> лабораторная выполнялась локально на MariaDB 11.4.14, GUI отсутствует.

## ✅ Чек-лист сдачи

- [ ] Контейнер `imfua-12-index` поднят в WSL, `general_log = ON`.
- [ ] Лог очищен до экспериментов (`-u mysql`).
- [ ] Эксперименты 1–6 выполнены в порядке из `03_queries.sql`.
- [ ] Таблица «до/после» заполнена реальными `type`, `rows`, `Extra`.
- [ ] Показано, что `YEAR()` даёт `ALL`, а диапазон — `range`.
- [ ] Показаны левый префикс составного индекса и `Using index`.
- [ ] Скриншоты в `evidence/`, лог и дамп в `artifacts/`.
- [ ] `my_actions.log` не содержит служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
