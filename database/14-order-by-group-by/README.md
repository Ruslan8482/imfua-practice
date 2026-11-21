# Лабораторная 14 — ускорение ORDER BY / GROUP BY

**Оригинал:** [ORDER_BY_GROUP_BY.md — Ускорение сортировки и группировки в MySQL](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/ORDER_BY_GROUP_BY.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/ORDER_BY_GROUP_BY.md`

> ⚠️ **Статус отчёта.** В этой среде нет Docker/MySQL: реальные логи, дампы и
> скриншоты создаются **при запуске на вашей машине** (инструкция требует WSL).
> Плейсхолдеры `<...>` ниже заменяются реальными значениями `EXPLAIN`.

## Цель

Понять, когда возникают `Using filesort` и `Using temporary`, и научиться
проектировать индексы под `ORDER BY` / `GROUP BY`: индекс по столбцу сортировки,
однородная и разнонаправленная сортировка, нисходящий индекс MySQL 8.0+,
`Loose Index Scan`, `Tight Index Scan` и покрывающий индекс для группировки.

## Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, general_log) |
| `01_schema.sql` | `CREATE DATABASE sort_practice`, таблица `orders` с `INDEX idx_customer` |
| `02_seed.sql` | 500 строк через `INSERT ... SELECT` (10 × 10 × 5), `SELECT COUNT(*)` |
| `03_queries.sql` | Эксперименты 1–7 строго по порядку |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, экспорт лога, дамп |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## Пошаговое выполнение

```bash
cd imfua-practice
make check
bash database/14-order-by-group-by/commands.sh    # контейнер imfua-14-order-by-group-by
```

Шаги `commands.sh`:

1. Удаляет старый контейнер/volume; **не** выполняет `docker volume prune -a`.
2. Копирует общий `my.cnf` в каталог задания.
3. `docker run --name imfua-14-order-by-group-by -e MYSQL_ROOT_PASSWORD=123 \
   -e LANG=C.UTF-8 -e MYSQL_INITDB_SKIP_TZINFO=1 -v <volume>:/var/lib/mysql \
   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Проверяет `general_log` / `log_output`; ждёт готовности сервера.
5. Очищает лог: `docker exec -u mysql imfua-14-order-by-group-by sh -c ': > /var/lib/mysql/general.log'`.
6. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql`.
7. `bash scripts/export-log.sh 14-order-by-group-by` и `bash scripts/dump-db.sh 14-order-by-group-by sort_practice`.

Интерактивно: `docker exec -it imfua-14-order-by-group-by mysql --default-character-set=utf8mb4 -uroot -p` (пароль `123`).

## Результаты: EXPLAIN «до/после»

| № / эксперимент | Запрос | До: `type / key / rows / Extra` | После: `type / key / rows / Extra` |
|-----------------|--------|----------------------------------|-------------------------------------|
| 1. ORDER BY без индекса | `EXPLAIN SELECT * FROM orders ORDER BY amount DESC;` | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `ALL` / `NULL` / `500` / `Using filesort`) | — |
| 2. `CREATE INDEX idx_amount` | тот же `EXPLAIN` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `index` / `idx_amount` / `500` / без `filesort`) |
| 3. `ORDER BY amount ASC` | `EXPLAIN SELECT * FROM orders ORDER BY amount ASC;` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (backward scan) |
| 3. Два столбца, одинаковое направление | `... ORDER BY status ASC, amount ASC;` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (`idx_status_amount`, без `filesort`) |
| 3. Разное направление | `... ORDER BY status ASC, amount DESC;` | `<type>` / `<key>` / `<rows>` / `<Extra>` (`Using filesort`) | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `idx_status_amount_desc`, без `filesort`) |
| 4. GROUP BY без индекса | `EXPLAIN SELECT status, COUNT(*) FROM orders GROUP BY status;` | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `Using temporary; Using filesort`) | — |
| 5. `CREATE INDEX idx_status` | тот же `EXPLAIN` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `index` / `idx_status` / `4`, без temporary) |
| 6. `Tight Index Scan` | `EXPLAIN SELECT status, SUM(amount) FROM orders GROUP BY status;` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (без `Using temporary`) |
| 7. Покрывающий индекс | `CREATE INDEX idx_status_amount_cover` + тот же `EXPLAIN` | `<type>` / `<key>` / `<rows>` / `<Extra>` | `<type>` / `<key>` / `<rows>` / `<Extra>` (ожидается `Using index`) |

Проверка данных: `SELECT COUNT(*) FROM orders;` → `<500>`; `SELECT status, COUNT(*) ...` → `<4 группы>`.

> Фактический план зависит от статистики и версии MySQL — вписывайте то, что
> реально вернул ваш `EXPLAIN`; ожидаемые значения в скобках — ориентир.

## Места под скриншоты (создаются при запуске)

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-count.png` | `SELECT COUNT(*) FROM orders;` = 500 |
| `evidence/02-order-by-before.png` | `EXPLAIN ... ORDER BY amount DESC` до индекса (`Using filesort`) |
| `evidence/03-order-by-after.png` | Тот же `EXPLAIN` после `idx_amount` |
| `evidence/04-mixed-direction.png` | `ORDER BY status ASC, amount DESC` до/после `idx_status_amount_desc` |
| `evidence/05-group-by-before.png` | `EXPLAIN ... GROUP BY status` с `Using temporary; Using filesort` |
| `evidence/06-loose-scan.png` | Тот же `EXPLAIN` после `idx_status` |
| `evidence/07-covering.png` | `EXPLAIN SELECT status, SUM(amount) ...` с `Using index` |
| `evidence/08-log-dump.png` | `head artifacts/my_actions.log`, `head artifacts/sort_practice-dump.sql` |

## Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только ваши действия) → отчёт.

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создаётся при запуске |
| `artifacts/my_actions.log` | Отфильтрованный лог | Создаётся при запуске |
| `artifacts/sort_practice-dump.sql` | Дамп 500 строк и всех индексов экспериментов | Создаётся при запуске |
| `database/logs/14-order-by-group-by-actions.log` | Копия лога | Создаётся при запуске |
| `database/dumps/14-order-by-group-by-sort_practice-dump.sql` | Копия дампа | Создаётся при запуске |

Логи, дампы и PNG игнорируются Git; коммитится только `artifacts/.gitkeep` и `evidence/.gitkeep`.

## Чек-лист сдачи

- [ ] MySQL 8.0 поднят с общим `my.cnf`, лог очищен до работы.
- [ ] Загружено ровно 500 строк (`SELECT COUNT(*)`).
- [ ] Эксперименты 1–7 выполнены в порядке файла `03_queries.sql`.
- [ ] Показано исчезновение `Using filesort` после `idx_amount`.
- [ ] Показано исчезновение `Using temporary` после `idx_status`.
- [ ] Показана разница однородной и разнонаправленной сортировки + нисходящий индекс.
- [ ] Получен `Using index` для покрывающего индекса.
- [ ] Таблица EXPLAIN «до/после» заполнена, скриншоты в `evidence/`.
- [ ] Лог и дамп в `artifacts/`; `my_actions.log` без служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.
