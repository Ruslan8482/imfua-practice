# Лабораторная 05 — представления (VIEW) в MySQL

> **Оригинал:** [VIEW_MySQL.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/VIEW_MySQL.md)
>
> **Внимание:** в этой среде нет Docker/MySQL. Реальные логи, дампы и скриншоты
> создаются при запуске на машине с Docker. Плейсхолдеры `<вставьте …>` и ссылки
> `evidence/*.png` заполняются после выполнения задания.

## Цель

Освоить представления: создать `moscow_customers`, `customer_summary`, `active_customers`,
`public_customers`; научиться просматривать и изменять VIEW, различать обновляемые и
необновляемые представления, использовать `WITH CHECK OPTION`, проверять план через
`EXPLAIN`, понимать работу VIEW с правами доступа; сделать дамп и выгрузить лог.

## Используемый образ и контейнер

- Образ: `mysql:8.0`; контейнер здесь — `imfua-05-view-mysql` (в инструкции — `my-mysql`).
- Пароль `root` — `123`; `MYSQL_INITDB_SKIP_TZINFO=1` уменьшает шум в логе.
- `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf): UTF-8 без BOM, LF,
  `general_log = 1`, `log_output = FILE`, лог в `/var/lib/mysql/general.log`.

## Ход выполнения

### Разделы 0-1. Конфиг и контейнер

```bash
# my.cnf: general_log = 1, general_log_file = /var/lib/mysql/general.log, log_output = FILE
docker restart my-mysql
# либо с нуля:
docker ps -a
docker stop my-mysql
docker rm my-mysql
docker volume prune -a              # осторожно: все неиспользуемые тома
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
  -d mysql:8.0
docker exec my-mysql sh -c ': > /var/lib/mysql/general.log'
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

### Раздел 2. БД и данные (01_schema.sql, 02_seed.sql)

```sql
CREATE DATABASE sql_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sql_practice;
-- customers и orders с FOREIGN KEY (customer_id) REFERENCES customers(id)
-- 5 клиентов и 6 заказов — точные INSERT см. в 02_seed.sql
SHOW TABLES;
SELECT * FROM customers;
SELECT * FROM orders;
```

### Разделы 4-5. Простой VIEW и VIEW с JOIN/агрегацией (03_views.sql)

```sql
CREATE VIEW moscow_customers AS
SELECT id, name, email
FROM customers
WHERE city = 'Москва';
SELECT * FROM moscow_customers;     -- Иван Иванов, Мария Сидорова

CREATE VIEW customer_summary AS
SELECT c.id, c.name, c.city,
       COUNT(o.id)              AS order_count,
       COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.city;

SELECT * FROM customer_summary ORDER BY total_amount DESC;
SELECT name, total_amount FROM customer_summary WHERE total_amount > 2000;
```

VIEW не хранит данные: запрос выполняется заново при каждом обращении.

### Разделы 6-8. Фильтрация, просмотр, изменение, удаление

```sql
SELECT * FROM customer_summary WHERE city = 'Москва';
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SHOW TABLES;
SHOW CREATE VIEW customer_summary\G     -- интерактивно; в файле: SHOW CREATE VIEW customer_summary;

CREATE OR REPLACE VIEW moscow_customers AS
SELECT id, name, email, created_at
FROM customers
WHERE city = 'Москва';
SELECT * FROM moscow_customers;

DROP VIEW moscow_customers;
DROP VIEW IF EXISTS moscow_customers;
SHOW TABLES;
```

### Разделы 9-10. Обновляемость и производительность

```sql
CREATE VIEW active_customers AS
SELECT id, name, email, city
FROM customers
WHERE city IS NOT NULL;

UPDATE active_customers SET city = 'Сочи' WHERE id = 2;
INSERT INTO active_customers (name, email, city)
VALUES ('Новый Клиент', 'new@example.com', 'Уфа');
DELETE FROM active_customers WHERE id = 6;

CREATE OR REPLACE VIEW customer_summary AS
SELECT c.id, c.name, COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- UPDATE customer_summary SET name = 'X' WHERE id = 1;
-- ERROR 1288 (HY000): ... is not updatable (COUNT — агрегат)

EXPLAIN SELECT * FROM customer_summary WHERE city = 'Москва';  -- для исходного определения
EXPLAIN SELECT * FROM customer_summary;                       -- для текущего
```

В [03_views.sql](03_views.sql) оба `EXPLAIN` выполнены в корректном порядке: первый —
до переопределения `customer_summary`, когда в нём ещё есть `city`.

### Разделы 11-12. WITH CHECK OPTION и права (04_check_rights.sql)

```sql
CREATE OR REPLACE VIEW moscow_customers AS
SELECT id, name, email, city FROM customers WHERE city = 'Москва';

INSERT INTO moscow_customers (name, email, city)
VALUES ('Пётр Второй', 'petr2@example.com', 'Казань');
SELECT * FROM customers WHERE email = 'petr2@example.com';   -- строка есть
SELECT * FROM moscow_customers;                              -- но через VIEW не видна

CREATE OR REPLACE VIEW moscow_customers AS
SELECT id, name, email, city FROM customers WHERE city = 'Москва'
WITH CHECK OPTION;
-- INSERT ... ('Пётр Третий', 'petr3@example.com', 'Казань') -> ERROR 1369

DELETE FROM customers WHERE email IN ('petr2@example.com', 'petr3@example.com');

CREATE VIEW public_customers AS
SELECT id, name, city FROM customers;    -- без email
CREATE USER 'analyst'@'%' IDENTIFIED BY 'pass';
GRANT SELECT ON sql_practice.public_customers TO 'analyst'@'%';
```

### Разделы 13-14. Дамп и лог

```bash
\q
docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot sql_practice > dump.sql
cat dump.sql
cd database
bash ../scripts/dump-db.sh 05-view-mysql sql_practice

docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'log_output';
\q
docker cp my-mysql:/var/lib/mysql/general.log ./general.log
docker exec my-mysql cat /var/lib/mysql/general.log \
  | grep "Query" \
  | grep -v -E "SET NAMES|SET autocommit|SET sql_mode|SET character_set_results|SHOW VARIABLES|SHOW STATUS|SHOW WARNINGS|SELECT @@|SELECT DATABASE\(\)|time_zone" \
  > my_actions.log
cat my_actions.log
docker exec my-mysql sh -c ': > /var/lib/mysql/general.log'    # очистка при необходимости
bash ../scripts/export-log.sh 05-view-mysql
```

Полная последовательность — в [commands.sh](commands.sh).

## Результаты

**Ожидаемые контрольные значения:**

- `moscow_customers` → 2 строки: Иван Иванов, Мария Сидорова.
- `customer_summary` → 5 строк; максимум `5300.00` у Марии Сидоровой;
  у Ольги Кузнецовой `order_count = 0`, `total_amount = 0.00`.
- Попытка `UPDATE customer_summary` → `ERROR 1288`; вставка Казани через VIEW
  с `WITH CHECK OPTION` → `ERROR 1369`.
- `SHOW FULL TABLES WHERE Table_type = 'VIEW'` → созданные VIEW.

**Фактический вывод (заполнить):**

```text
<вставьте вывод SELECT * FROM moscow_customers и customer_summary>
<вставьте вывод SHOW CREATE VIEW, SHOW FULL TABLES и EXPLAIN>
<вставьте вывод проверок WITH CHECK OPTION и прав analyst>
```

![Простой VIEW](evidence/01-moscow-customers.png)
![VIEW с JOIN и агрегатами](evidence/02-customer-summary.png)
![WITH CHECK OPTION](evidence/03-check-option.png)
![EXPLAIN VIEW](evidence/04-explain.png)

## Лог и дамп

- `artifacts/general.log` — сырой лог из `/var/lib/mysql/general.log`.
- `artifacts/my_actions.log` — отфильтрованный лог действий пользователя.
- `artifacts/sql_practice-dump.sql` — дамп (аналог `dump.sql` из инструкции);
  `mysqldump` по умолчанию включает определения VIEW.

![Лог действий](evidence/05-log.png)
![Дамп с VIEW](evidence/06-dump.png)

## Чек-лист сдачи

- [ ] `my.cnf` без BOM/CRLF, `general_log` включён, лог очищен перед работой.
- [ ] БД `sql_practice`, таблицы `customers`/`orders` созданы и заполнены.
- [ ] Созданы VIEW `moscow_customers`, `customer_summary`, `active_customers`,
      `public_customers`; проверены `SHOW FULL TABLES` и `SHOW CREATE VIEW`.
- [ ] Показаны обновляемые и необновляемые VIEW (ожидаемые ошибки 1288/1369 задокументированы).
- [ ] Выполнен `EXPLAIN`, дамп содержит VIEW.
- [ ] Лог выгружен и отфильтрован; дамп не пуст.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.
