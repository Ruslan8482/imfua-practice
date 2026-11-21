# Лабораторная 01 — SQL-команды для создания и заполнения нормализованных таблиц

> **Оригинал:** [Lesson_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Lesson_1.md)
>
> **Внимание:** в этой среде нет Docker/MySQL. Здесь лежат готовые SQL-скрипты,
> `my.cnf` и шаблон отчёта. Реальные логи, дампы и скриншоты создаются **при запуске
> на вашей машине** (см. [docs/workflow.md](../../docs/workflow.md)). Плейсхолдеры
> вида `<вставьте вывод …>` и ссылки `evidence/*.png` нужно заменить фактическими
> результатами после выполнения лабораторной.

## Цель

Создать базу `sales` и четыре нормализованные таблицы — `customers`, `products`,
`reports`, `report_items` — заполнить их данными из инструкции и запросом с `JOIN`
восстановить исходную «плоскую» таблицу. Порядок создания/заполнения: от независимых
таблиц к зависимым, чтобы внешние ключи не нарушались.

## Используемый образ и контейнер

- Образ: `mysql:8.0` (LTS, как в инструкции).
- Контейнер в этом репозитории: `imfua-01-lesson-1`; в оригинале — `my-mysql`.
- Пароль `root` из инструкции — `123` (в `commands.sh` он передан явно).
- Конфиг: `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf), UTF-8 без
  BOM, LF; включает `general_log = 1`, `general_log_file = /var/lib/mysql/general.log`,
  `log_output = FILE`.

## Ход выполнения

### 1. Подготовка (Git-Bash / WSL)

```bash
cd imfua-practice
make check
make run-lab LAB=01-lesson-1
# либо по инструкции: создать каталог my-mysql и my.cnf, затем
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
  -d mysql:8.0
docker ps
```

> При использовании собственного контейнера с паролем `123` вызовы helper-скриптов
> выполняются с `MYSQL_PASSWORD=123`. Опасные команды из инструкции
> (`docker stop $(docker ps -q)`, `docker container prune`, `docker volume prune -a`)
> удаляют **всё** неиспользуемое в Docker — выполняйте их только если уверены, что
> других важных контейнеров нет.

### 2. Очистить лог и войти в MySQL

```bash
docker exec imfua-01-lesson-1 sh -c ': > /var/lib/mysql/general.log'
docker exec -it imfua-01-lesson-1 mysql --default-character-set=utf8mb4 -uroot -p
# пароль: 123; выход из клиента: \q
```

### 3. Создать БД и таблицы (01_schema.sql)

```sql
SHOW DATABASES;
CREATE DATABASE sales
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sales;
-- customers, products, reports, report_items — см. 01_schema.sql
-- внешние ключи: reports.customer_id -> customers.customer_id;
-- report_items.report_id -> reports.report_id;
-- report_items.product_id -> products.product_id
```

### 4. Заполнить таблицы (02_seed.sql)

```sql
INSERT INTO customers (customer_id, customer_name) VALUES
  (12, 'Дания'), (23, 'Испания'), (25, 'Албания');
INSERT INTO products (product_id, product_name, price) VALUES
  (101, 'Дыня', 800), (102, 'Клубника', 150),
  (103, 'Яблоко', 120), (104, 'Лимон', 200);
INSERT INTO reports (report_id, report_date, customer_id) VALUES
  (1101, '2026-03-05', 12), (1102, '2026-03-07', 23),
  (1103, '2026-03-08', 25), (1104, '2026-03-10', 12),
  (1105, '2026-03-12', 25);
INSERT INTO report_items (report_id, product_id, quantity) VALUES
  (1101, 101, 1100), (1101, 102, 300), (1102, 103, 1700),
  (1103, 104, 500), (1104, 101, 2500),
  (1105, 103, 2000), (1105, 104, 700);
```

### 5. Проверить данные (03_queries.sql)

```sql
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM reports;
SELECT * FROM report_items;

SELECT r.report_id, r.report_date, c.customer_name,
       p.product_name, p.price, ri.quantity
FROM reports r
JOIN customers c   ON r.customer_id = c.customer_id
JOIN report_items ri ON r.report_id = ri.report_id
JOIN products p    ON ri.product_id = p.product_id
ORDER BY r.report_id, p.product_id;
```

### 6. Выгрузить лог и дамп

```bash
docker exec my-mysql ls -la /var/lib/mysql/general.log
docker exec my-mysql cat /var/lib/mysql/general.log | grep "Query" \
  | grep -v -E "SET NAMES|SET autocommit|SET sql_mode|SET character_set_results|SHOW VARIABLES|SHOW STATUS|SHOW WARNINGS|SELECT @@|SELECT DATABASE\(\)|time_zone" \
  > my_actions.log
cd database
bash ../scripts/export-log.sh 01-lesson-1
bash ../scripts/dump-db.sh 01-lesson-1 sales
```

Полная последовательность команд с именами контейнеров этого репозитория —
в [commands.sh](commands.sh).

## Результаты

> Заполняется после запуска. Ожидаемые контрольные значения ниже; вставьте реальный
> вывод и скриншоты.

**Список таблиц (ожидается):** `customers`, `products`, `reports`, `report_items`.

**Результат запроса с JOIN (ожидается 7 строк):**

| report_id | report_date | customer_name | product_name | price | quantity |
|-----------|-------------|---------------|--------------|-------|----------|
| 1101      | 2026-03-05  | Дания         | Дыня         | 800   | 1100     |
| 1101      | 2026-03-05  | Дания         | Клубника     | 150   | 300      |
| 1102      | 2026-03-07  | Испания       | Яблоко       | 120   | 1700     |
| 1103      | 2026-03-08  | Албания       | Лимон        | 200   | 500      |
| 1104      | 2026-03-10  | Дания         | Дыня         | 800   | 2500     |
| 1105      | 2026-03-12  | Албания       | Яблоко       | 120   | 2000     |
| 1105      | 2026-03-12  | Албания       | Лимон        | 200   | 700      |

**Фактический вывод (заполнить):**

```text
<вставьте вывод SHOW TABLES и SELECT * FROM customers/products/reports/report_items>
<вставьте вывод итогового JOIN-запроса>
```

![Таблицы базы sales](evidence/01-tables.png)
![Результат JOIN-запроса](evidence/02-join-result.png)

## Лог и дамп

Файлы создаются при запуске скриптов; в репозитории каталоги пока пустые
(`.gitkeep`).

- `artifacts/general.log` — сырой лог MySQL из контейнера.
- `artifacts/my_actions.log` — отфильтрованный лог (только осмысленные действия).
- `artifacts/sales-dump.sql` — дамп БД `sales` без GTID
  (`--set-gtid-purged=OFF --single-transaction`).

![Фрагмент отфильтрованного лога](evidence/03-log.png)
![Фрагмент дампа](evidence/04-dump.png)

## Чек-лист сдачи

- [ ] Контейнер поднят из `mysql:8.0`, `my.cnf` без BOM и с LF, лог включён.
- [ ] БД `sales` и таблицы `customers`, `products`, `reports`, `report_items` созданы.
- [ ] Внешние ключи созданы, данные вставлены в порядке инструкции.
- [ ] Итоговый `JOIN` вернул 7 строк, совпадающих с таблицей инструкции.
- [ ] `artifacts/my_actions.log` содержит только действия пользователя.
- [ ] `artifacts/sales-dump.sql` создан и не пуст.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.
