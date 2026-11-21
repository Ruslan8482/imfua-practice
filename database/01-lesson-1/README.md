### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Lesson_1.md)

# Лабораторная 01 — SQL-команды для создания и заполнения нормализованных таблиц

> **Оригинал:** [Lesson_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Lesson_1.md)
>
> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

Создать базу `sales` и четыре нормализованные таблицы — `customers`, `products`,
`reports`, `report_items` — заполнить их данными из инструкции и запросом с `JOIN`
восстановить исходную «плоскую» таблицу. Порядок создания/заполнения: от независимых
таблиц к зависимым, чтобы внешние ключи не нарушались.

## 🧰 Используемый образ и контейнер

- Образ: `mysql:8.0` (LTS, как в инструкции).
- Контейнер в этом репозитории: `imfua-01-lesson-1`; в оригинале — `my-mysql`.
- Пароль `root` из инструкции — `123` (в `commands.sh` он передан явно).
- Конфиг: `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf), UTF-8 без
  BOM, LF; включает `general_log = 1`, `general_log_file = /var/lib/mysql/general.log`,
  `log_output = FILE`.

## 📋 Ход выполнения

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

## 📊 Результаты

Все три SQL-файла выполнены с кодом возврата 0, ошибок в выводе нет
(см. [RESULT.txt](artifacts/RESULT.txt)).

**Список таблиц (`SHOW TABLES`, факт):** `customers`, `products`, `report_items`, `reports`.

**Результат запроса с JOIN (факт — 7 строк, совпадает с контрольной таблицей):**

| report_id | report_date | customer_name | product_name | price | quantity |
|-----------|-------------|---------------|--------------|-------|----------|
| 1101      | 2026-03-05  | Дания         | Дыня         | 800   | 1100     |
| 1101      | 2026-03-05  | Дания         | Клубника     | 150   | 300      |
| 1102      | 2026-03-07  | Испания       | Яблоко       | 120   | 1700     |
| 1103      | 2026-03-08  | Албания       | Лимон        | 200   | 500      |
| 1104      | 2026-03-10  | Дания         | Дыня         | 800   | 2500     |
| 1105      | 2026-03-12  | Албания       | Яблоко       | 120   | 2000     |
| 1105      | 2026-03-12  | Албания       | Лимон        | 200   | 700      |

**Фактический вывод (`execution-output.txt`, дословно):**

```text
===== BEGIN 01_schema.sql =====
Tables_in_sales
customers
products
report_items
reports
===== END 01_schema.sql : exit=0 =====
===== BEGIN 02_seed.sql =====
===== END 02_seed.sql : exit=0 =====
===== BEGIN 03_queries.sql =====
customer_id	customer_name
12	Дания
23	Испания
25	Албания
product_id	product_name	price
101	Дыня	800
102	Клубника	150
103	Яблоко	120
104	Лимон	200
report_id	report_date	customer_id
1101	2026-03-05	12
1102	2026-03-07	23
1103	2026-03-08	25
1104	2026-03-10	12
1105	2026-03-12	25
report_id	product_id	quantity
1101	101	1100
1101	102	300
1102	103	1700
1103	104	500
1104	101	2500
1105	103	2000
1105	104	700
report_id	report_date	customer_name	product_name	price	quantity
1101	2026-03-05	Дания	Дыня	800	1100
1101	2026-03-05	Дания	Клубника	150	300
1102	2026-03-07	Испания	Яблоко	120	1700
1103	2026-03-08	Албания	Лимон	200	500
1104	2026-03-10	Дания	Дыня	800	2500
1105	2026-03-12	Албания	Яблоко	120	2000
1105	2026-03-12	Албания	Лимон	200	700
===== END 03_queries.sql : exit=0 =====
```

Скриншоты в `evidence/` не создавались (нет GUI).

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — сырой `general.log` сервера MariaDB (2947 байт).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованный лог действий пользователя (71 строка).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — полный вывод всех трёх SQL-скриптов (1121 байт).
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — сводка прогона: коды возврата 0, 0 ошибок, 0 фатальных ошибок.
- [artifacts/sales-dump.sql](artifacts/sales-dump.sql) — дамп БД `sales` (4543 байт).

## ✅ Чек-лист сдачи

- [ ] Контейнер поднят из `mysql:8.0`, `my.cnf` без BOM и с LF, лог включён.
- [ ] БД `sales` и таблицы `customers`, `products`, `reports`, `report_items` созданы.
- [ ] Внешние ключи созданы, данные вставлены в порядке инструкции.
- [ ] Итоговый `JOIN` вернул 7 строк, совпадающих с таблицей инструкции.
- [ ] `artifacts/my_actions.log` содержит только действия пользователя.
- [ ] `artifacts/sales-dump.sql` создан и не пуст.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
