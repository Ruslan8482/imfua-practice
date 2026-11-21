-- ============================================================
-- Лабораторная 03, шаги 5-7: агрегаты, GROUP BY/HAVING и JOIN.
-- ============================================================

USE sql_practice;

-- ---------- Шаг 5: агрегатные функции ----------
SELECT COUNT(*) AS total_orders FROM orders;
SELECT SUM(amount) AS total_sum FROM orders;
SELECT AVG(amount) AS avg_amount FROM orders;
SELECT MIN(amount) AS min_amount, MAX(amount) AS max_amount FROM orders;

-- ---------- Шаг 6: GROUP BY и HAVING ----------
-- 6.1. Количество заказов по каждому клиенту
SELECT customer_id, COUNT(*) AS order_count, SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id;

-- 6.2. Соединение с именами клиентов
SELECT c.name, COUNT(o.id) AS order_count, SUM(o.amount) AS total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;

-- 6.3. Фильтрация групп HAVING
SELECT customer_id, SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 2000;

-- ---------- Шаг 7: соединения JOIN ----------
-- 7.1. INNER JOIN (JOIN = INNER JOIN)
SELECT c.name, o.order_date, o.amount, o.status
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;

-- Разрешение неоднозначности столбца id с помощью алиасов:
SELECT c.id, o.id FROM customers c JOIN orders o ON c.id = o.customer_id;
-- Запрос без алиаса из инструкции НЕ выполняем:
-- SELECT id FROM customers JOIN orders ON ...;  -- ERROR 1052: Column 'id' is ambiguous

-- 7.2. LEFT JOIN — все клиенты, даже без заказов
SELECT c.name, o.id AS order_id, o.amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

-- 7.3. RIGHT JOIN — все заказы, даже если клиент удалён
SELECT c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

-- Эквивалент RIGHT JOIN через LEFT JOIN
SELECT c.name, o.id AS order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id;

-- 7.4. JOIN и GROUP BY
SELECT c.name,
       COUNT(o.id) AS order_count,
       SUM(o.amount) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;

-- Чтобы вместо NULL был 0:
SELECT c.name,
       COUNT(o.id) AS order_count,
       COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;
