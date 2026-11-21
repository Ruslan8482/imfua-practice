-- ============================================================
-- Лабораторная 11: алиасы в MySQL
-- Источник: Aliases.md, разделы 1-9.
-- Разделы 10 (лог) и 11 (дамп) выполняются командами из commands.sh.
--
-- ВАЖНО: запросы, помеченные «НЕ ВЫПОЛНЯТЬ», — это намеренно ошибочные
-- примеры из инструкции. Они оставлены комментариями, чтобы скрипт
-- выполнился до конца без остановки на ошибке.
-- ============================================================

USE alias_db;

-- ------------------------------------------------------------
-- 1. Зачем нужны алиасы (таблица возможностей из инструкции):
--    customers -> c; c.id / o.id при неоднозначности;
--    SUM(amount) -> total_amount; ORDER BY total_amount;
--    self-join: employees e и employees m.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 2. Алиасы таблиц
-- Синтаксис: FROM имя_таблицы [AS] псевдоним  (AS необязателен).
-- ------------------------------------------------------------

-- Пример без алиасов (Aliases.md, 2):
SELECT customers.name, orders.order_date, orders.amount
FROM customers
JOIN orders ON customers.id = orders.customer_id;

-- Тот же запрос с алиасами:
SELECT c.name, o.order_date, o.amount
FROM customers c
JOIN orders o ON c.id = o.customer_id;

-- До/после для отчёта: два плана должны быть одинаковыми
-- (алиасы не меняют план, меняют только читаемость SQL).
EXPLAIN
SELECT customers.name, orders.order_date, orders.amount
FROM customers
JOIN orders ON customers.id = orders.customer_id;

EXPLAIN
SELECT c.name, o.order_date, o.amount
FROM customers c
JOIN orders o ON c.id = o.customer_id;

-- 2.1. Самосоединение — алиасы обязательны:
SELECT e.name AS employee, m.name AS manager
FROM employees e
JOIN employees m ON e.manager_id = m.id;

-- 2.2. Неоднозначные имена столбцов:
-- НЕ ВЫПОЛНЯТЬ (ожидаемая ошибка): Column 'id' in field list is ambiguous
-- SELECT id FROM customers JOIN orders ON customers.id = orders.customer_id;
-- Правильно:
SELECT c.id, o.id
FROM customers c
JOIN orders o ON c.id = o.customer_id;

-- 2.3. Производная таблица в FROM — алиас обязателен:
SELECT *
FROM (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
) AS t;
-- НЕ ВЫПОЛНЯТЬ (ожидаемая ошибка): без AS t
-- SELECT * FROM (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id);

-- ------------------------------------------------------------
-- 3. Алиасы столбцов
-- ------------------------------------------------------------
SELECT name AS customer_name,
       email AS contact_email
FROM customers;

SELECT customer_id,
       COUNT(*) AS order_count,
       SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id;

-- Алиас в ORDER BY — работает (ORDER BY выполняется после SELECT):
SELECT id, amount * 2 AS double_amount
FROM orders
ORDER BY double_amount DESC;

-- НЕ ВЫПОЛНЯТЬ (ожидаемая ошибка): Unknown column 'double_amount' in 'where clause'
-- SELECT id, amount * 2 AS double_amount FROM orders WHERE double_amount > 1000;
-- Правильно — повторяем выражение в WHERE:
SELECT id, amount * 2 AS double_amount
FROM orders
WHERE amount * 2 > 1000;

-- MySQL разрешает алиас в GROUP BY и HAVING (нестандартное расширение):
SELECT customer_id, SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id
HAVING total_amount > 1000;

-- ------------------------------------------------------------
-- 4. Порядок выполнения запроса (шпаргалка из раздела 4):
--    1) FROM / JOIN     — алиасы столбцов не видны
--    2) WHERE           — не видны
--    3) GROUP BY        — частично (MySQL разрешает)
--    4) HAVING          — частично (MySQL разрешает)
--    5) SELECT          — здесь алиасы создаются
--    6) ORDER BY        — видны
--    7) LIMIT           — видны
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 5. Алиасы в подзапросах
-- 5.1. Производная таблица (псевдоним o обязателен):
SELECT c.name, o.total
FROM customers c
JOIN (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
) o ON c.id = o.customer_id
WHERE o.total > 2000;

-- 5.2. Скалярный подзапрос в SELECT:
SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM customers c;

-- ------------------------------------------------------------
-- 6. Алиасы и JOIN
-- ------------------------------------------------------------
SELECT c.name AS customer,
       o.order_date,
       o.amount,
       o.amount * 2 AS double_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'paid'
ORDER BY double_amount DESC;

-- ------------------------------------------------------------
-- 7. Распространённые ошибки (все ошибочные запросы — комментарии)
-- 7.1. Старое имя таблицы после объявления алиаса
-- НЕ ВЫПОЛНЯТЬ: SELECT customers.name FROM customers c;
SELECT c.name FROM customers c;

-- 7.2. Пропущен AS у производной таблицы
-- НЕ ВЫПОЛНЯТЬ: SELECT * FROM (SELECT id FROM customers);
SELECT * FROM (SELECT id FROM customers) AS t;

-- 7.3. Алиас в WHERE
-- НЕ ВЫПОЛНЯТЬ: SELECT amount * 2 AS double_amount FROM orders WHERE double_amount > 1000;
SELECT amount * 2 AS double_amount FROM orders WHERE amount * 2 > 1000;

-- 7.4. Неоднозначный id без алиаса
-- НЕ ВЫПОЛНЯТЬ: SELECT id FROM customers JOIN orders ON customers.id = orders.customer_id;
SELECT c.id, o.id FROM customers c JOIN orders o ON c.id = o.customer_id;

-- 7.5. Забытый алиас в самосоединении
-- НЕ ВЫПОЛНЯТЬ: SELECT * FROM employees JOIN employees ON ...;
SELECT e.name, m.name
FROM employees e
JOIN employees m ON e.manager_id = m.id;

-- ------------------------------------------------------------
-- 8. Шпаргалка:
--    табличный      FROM customers c          AS не обязателен
--    столбцовый     SUM(x) AS total           AS рекомендуется
--    производная    (SELECT ...) AS t         AS обязателен
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 9. Полный пример «до и после»
-- 9.1. Без алиасов:
SELECT customers.name,
       COUNT(orders.id) AS order_count,
       SUM(orders.amount) AS total_amount
FROM customers
JOIN orders ON customers.id = orders.customer_id
GROUP BY customers.id, customers.name
ORDER BY total_amount DESC;

-- 9.2. С алиасами:
SELECT c.name,
       COUNT(o.id) AS order_count,
       SUM(o.amount) AS total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;

-- 10. Ведение лога и 11. Дамп: см. commands.sh (general.log ->
--     artifacts/my_actions.log и artifacts/alias_db-dump.sql).
