### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_2.md)

# Лабораторная 03 — интерактивная работа с MySQL в Docker № 2

> **Оригинал:** [Begin_MySQL_2.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_2.md)
>
> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

Настроить логирование в таблицу `mysql.general_log`, создать БД `sql_practice`,
таблицы `customers`/`orders` и VIEW `my_actions`; отработать `SELECT`, агрегаты,
`GROUP BY`/`HAVING`, `JOIN`, подзапросы, `UNION`, `UPDATE`, `DELETE`, `ALTER TABLE`;
сделать дамп, удалить и восстановить БД.

## 🧰 Используемый образ и контейнер

- Образ: `mysql:8.0`; контейнер здесь: `imfua-03-begin-mysql-2` (в инструкции — `my-mysql`).
- Пароль `root` — `123`; при первом запуске добавлен `MYSQL_INITDB_SKIP_TZINFO=1`.
- `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf) (UTF-8 без BOM, LF).
  **Отличие от оригинала:** в инструкции для этого задания стоит `log_output = TABLE`,
  в общем конфиге — `log_output = FILE`. Эквивалент достигается шагом 1.1:
  `SET GLOBAL general_log = 'ON'; SET GLOBAL log_output = 'TABLE';`.
  Для выгрузки `general.log` через `scripts/export-log.sh` шаг 12 дополнительно
  включает `TABLE,FILE` (этот режим прямо описан в инструкции).

## 📋 Ход выполнения

### Подготовка

```bash
docker restart my-mysql                  # если контейнер уже есть
# либо с нуля:
docker volume prune -a                   # осторожно: удаляет все неиспользуемые тома
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
  -d mysql:8.0
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
# При ERROR 2002 подождать 10-20 с и повторить.
```

### Шаг 1. Логирование и БД (01_setup.sql)

```sql
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'log_output';

CREATE DATABASE sql_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sql_practice;
SHOW DATABASES;
SHOW TABLES;

CREATE OR REPLACE VIEW my_actions AS
SELECT event_time, command_type,
       CONVERT(argument USING utf8mb4) AS argument
FROM mysql.general_log
WHERE user_host LIKE '%root%'
  AND command_type = 'Query'
  AND argument NOT LIKE 'SET %'
  AND argument NOT LIKE 'SHOW %'
  AND argument NOT LIKE 'SELECT @@%'
  AND argument NOT LIKE 'SELECT DATABASE()%'
  AND argument NOT LIKE 'SELECT * FROM my_actions%'
  AND argument NOT LIKE 'TRUNCATE TABLE mysql.general_log%'
  AND argument NOT LIKE 'CREATE OR REPLACE VIEW my_actions%';

SHOW FULL TABLES WHERE Table_type = 'VIEW';
SELECT * FROM my_actions ORDER BY event_time DESC LIMIT 20;
```

`FROM mysql.general_log` указан явно: без префикса MySQL искал бы таблицу в
`sql_practice`. Фильтр `%root%` работает и в 5.7, и в 8.0.

### Шаг 2. Таблицы (02_schema.sql)

```sql
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'new',
    FOREIGN KEY (customer_id) REFERENCES customers(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SHOW TABLES;
DESCRIBE customers;
DESCRIBE orders;
\q
docker exec -it my-mysql ls -la /var/lib/mysql/sql_practice   -- customers.ibd, orders.ibd
```

### Шаг 3. Данные (03_seed.sql)

5 клиентов (`Иван Иванов`, `Пётр Петров`, `Мария Сидорова`, `Алексей Смирнов`,
`Ольга Кузнецова`) и 6 заказов (`2026-10-01` … `2026-10-12`, статусы `paid`, `new`,
`cancelled`) — точные `INSERT` приведены в [03_seed.sql](03_seed.sql).

### Шаг 4. SELECT (04_select.sql)

`SELECT *`, проекция, `WHERE`, `ORDER BY`, `LIMIT`, `LIKE`, `BETWEEN`, `IN`,
`IS NULL` — все запросы из инструкции перенесены в [04_select.sql](04_select.sql).

### Шаг 5. Агрегаты (05_aggregates_joins.sql)

```sql
SELECT COUNT(*) AS total_orders FROM orders;
SELECT SUM(amount) AS total_sum FROM orders;
SELECT AVG(amount) AS avg_amount FROM orders;
SELECT MIN(amount) AS min_amount, MAX(amount) AS max_amount FROM orders;
```

### Шаг 6. GROUP BY / HAVING

```sql
SELECT customer_id, COUNT(*) AS order_count, SUM(amount) AS total_amount
FROM orders GROUP BY customer_id;

SELECT c.name, COUNT(o.id) AS order_count, SUM(o.amount) AS total_amount
FROM customers c JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name ORDER BY total_amount DESC;

SELECT customer_id, SUM(amount) AS total_amount
FROM orders GROUP BY customer_id HAVING SUM(amount) > 2000;
```

### Шаг 7. JOIN

`INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, эквивалент `RIGHT JOIN` через `LEFT JOIN`,
а также `JOIN + GROUP BY` и вариант с `COALESCE(SUM(o.amount), 0)` —
в [05_aggregates_joins.sql](05_aggregates_joins.sql). Алиасы `c`/`o` обязательны,
иначе `SELECT id …` даёт `ERROR 1052 (23000): Column 'id' in field list is ambiguous`.

### Шаг 8. Подзапросы и UNION (06_subqueries_union.sql)

Подзапросы в `WHERE` (`IN`, сравнение), в `FROM`, в `SELECT`, `EXISTS`/`NOT EXISTS`,
`UNION` и `UNION ALL` — все запросы из инструкции.

### Шаги 9-11. UPDATE / DELETE / ALTER (07_modify.sql)

```sql
UPDATE customers SET city = 'Екатеринбург' WHERE id = 4;
UPDATE orders SET status = 'paid' WHERE id = 3;
DELETE FROM orders WHERE id = 6;

ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
UPDATE customers SET phone = '123-36-77' WHERE id = 4;
ALTER TABLE customers MODIFY COLUMN phone VARCHAR(30);
ALTER TABLE customers DROP COLUMN phone;
```

### Шаг 12. Лог и дамп

```sql
SELECT * FROM my_actions ORDER BY event_time DESC;
SELECT * FROM my_actions
WHERE argument LIKE '%customers%'
ORDER BY event_time DESC LIMIT 10;
SET GLOBAL log_output = 'TABLE,FILE';   -- чтобы general.log тоже писался
\q
```

```bash
docker exec -e MYSQL_PWD=123 my-mysql mysql -uroot \
  --default-character-set=utf8mb4 \
  -e "SELECT * FROM sql_practice.my_actions ORDER BY event_time DESC" \
  > my_actions_export.log
cat my_actions_export.log

docker exec my-mysql mysqldump -uroot -p123 sql_practice > dump.sql
docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot \
  --set-gtid-purged=OFF --single-transaction sql_practice > dump_clean.sql
cd database
bash ../scripts/dump-db.sh 03-begin-mysql-2 sql_practice
bash ../scripts/export-log.sh 03-begin-mysql-2
```

### Шаг 13. Удаление (09_drop.sql)

```sql
DROP TABLE orders;
SHOW TABLES;
DROP TABLE customers;
SHOW TABLES;
DROP DATABASE sql_practice;   -- VIEW my_actions исчезает вместе с БД
SHOW DATABASES;
```

### Шаг 14. Восстановление (10_restore.sql → импорт → 11_verify.sql)

```bash
docker ps -a
docker start my-mysql          # если контейнер остановлен
ls -lh dump_clean.sql
head -n 30 dump_clean.sql      # CREATE TABLE/INSERT, без SET @@GLOBAL.GTID_PURGED
```

```sql
CREATE DATABASE sql_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
```

```bash
docker exec -i my-mysql mysql -uroot -p123 sql_practice < dump_clean.sql
# --force применяйте только в крайнем случае: он игнорирует ВСЕ ошибки
```

```sql
USE sql_practice;
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM my_actions LIMIT 5;
```

VIEW `my_actions` входит в дамп `sql_practice` и восстанавливается вместе с БД.

Полная последовательность с именами контейнера этого репозитория —
в [commands.sh](commands.sh).

## 📊 Результаты

Все 11 SQL-файлов выполнены с кодом возврата 0, ошибок в выводе нет
(см. [RESULT.txt](artifacts/RESULT.txt)).

**Логирование (факт):**

```text
Variable_name	Value
general_log	ON
general_log_file	/tmp/opencode/mariadb/data/general.log
Variable_name	Value
log_output	FILE,TABLE
```

**Схема и VIEW (факт):** `SHOW FULL TABLES WHERE Table_type = 'VIEW'` →
`my_actions`; `SHOW TABLES` → `customers`, `my_actions`, `orders`.
`DESCRIBE customers` и `DESCRIBE orders` — в
[execution-output.txt](artifacts/execution-output.txt). VIEW `my_actions`
вывел 20 последних событий, включая `CREATE DATABASE sql_practice`,
`DROP DATABASE my_database`, `DELETE FROM users WHERE id = 2` и т.д.

**Агрегаты (факт из `05_aggregates_joins.sql`):**

```text
total_orders
6
total_sum
10850.50
avg_amount
1808.416667
min_amount	max_amount
800.00	4200.00
```

⚠️ Контрольные значения в шаблоне (`total_sum = 11250.50`,
`avg_amount = 1875.083333`) отличаются от фактических; в отчёте указаны только
значения, реально полученные в выводе.

**`GROUP BY` / `HAVING` (факт):**

```text
customer_id	order_count	total_amount
1	2	3800.50
2	1	800.00
3	2	5300.00
4	1	950.00
name	order_count	total_amount
Мария Сидорова	2	5300.00
Иван Иванов	2	3800.50
Алексей Смирнов	1	950.00
Пётр Петров	1	800.00
customer_id	total_amount
1	3800.50
3	5300.00
```

**`JOIN` (факт):** `INNER JOIN` вернул 6 строк (Иван ×2, Пётр, Мария ×2, Алексей);
`LEFT JOIN` добавил `Ольга Кузнецова | NULL | NULL`, а с `COALESCE` —
`Ольга Кузнецова | 0 | 0.00`; `RIGHT JOIN` и его эквивалент — по 6 строк.

**Подзапросы и `UNION` (факт):** клиенты из Москвы — Иван Иванов, Мария Сидорова;
`NOT IN` — Ольга Кузнецова; `UNION` (name, city) для Москва + Казань дал 3 строки
(Иван Иванов, Мария Сидорова, Алексей Смирнов), `UNION ALL` для городов — 10 строк
(по 5 от каждого `SELECT`, дубликаты сохранены).

**`UPDATE` / `DELETE` / `ALTER` (факт):**

```text
4	Алексей Смирнов	alex@example.com	Екатеринбург	2026-11-21 22:39:42
3	2	2026-10-03	800.00	paid
4	Алексей Смирнов	alex@example.com	Екатеринбург	2026-11-21 22:39:42	123-36-77
```

Столбец `phone` добавлен (`123-36-77` у клиента 4), изменён на `VARCHAR(30)`
и удалён; заказ 6 удалён (осталось 5 заказов).

**Удаление и восстановление (факт):** после `DROP TABLE orders` → `customers`,
`my_actions`; после `DROP TABLE customers` → `my_actions`; после
`DROP DATABASE sql_practice` базы в списке нет. После импорта дампа — 5 клиентов,
5 заказов и VIEW `my_actions` на месте (строка
`my_actions	VIEW` в `SHOW FULL TABLES`).

Полный вывод всех шагов (включая большой вывод VIEW в `08_log_dump.sql`) —
в [execution-output.txt](artifacts/execution-output.txt).

Скриншоты в `evidence/` не создавались (нет GUI).

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — сырой `general.log` MariaDB (20755 байт).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованный лог действий (367 строк).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — полный вывод 11 SQL-скриптов (21145 байт).
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — сводка прогона: коды возврата 0, 0 ошибок.
- [artifacts/sql_practice-dump.sql](artifacts/sql_practice-dump.sql) — дамп БД `sql_practice` без GTID (6038 байт).
- [artifacts/sql_practice-pre-drop-dump.sql](artifacts/sql_practice-pre-drop-dump.sql) — дамп перед удалением БД (5528 байт).

## ✅ Чек-лист сдачи

- [ ] Лог включён, `log_output = TABLE` (затем `TABLE,FILE` для выгрузки).
- [ ] БД `sql_practice`, таблицы `customers`/`orders` и VIEW `my_actions` созданы.
- [ ] Выполнены все запросы шагов 4-8 (SELECT, агрегаты, GROUP BY, JOIN, UNION).
- [ ] Выполнены UPDATE, DELETE и ALTER TABLE (add/modify/drop phone).
- [ ] Лог просмотрен через VIEW и выгружен в файл; дамп создан без GTID.
- [ ] Таблицы и БД удалены, пустая БД создана, дамп импортирован, данные проверены.
- [ ] VIEW `my_actions` присутствует после восстановления.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
