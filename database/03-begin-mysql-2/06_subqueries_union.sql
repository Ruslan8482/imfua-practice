-- ============================================================
-- Лабораторная 03, шаг 8: подзапросы и UNION.
-- ============================================================

USE sql_practice;

-- ---------- 8.1. Подзапросы ----------
-- Подзапрос в WHERE с IN
SELECT name, city
FROM customers
WHERE id IN (
    SELECT customer_id
    FROM orders
    WHERE amount > 1000
);

-- Подзапрос в WHERE со сравнением
SELECT name, city
FROM customers
WHERE id = (
    SELECT customer_id
    FROM orders
    ORDER BY amount DESC
    LIMIT 1
);

-- Подзапрос в FROM (производная таблица)
SELECT c.name, o.total
FROM customers c
JOIN (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
) o ON c.id = o.customer_id
WHERE o.total > 2000;

-- Подзапрос в SELECT (скалярный)
SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM customers c;

-- EXISTS и NOT EXISTS
SELECT name FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);

SELECT name FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);

-- ---------- 8.2. UNION и UNION ALL ----------
-- UNION удаляет дубликаты
SELECT name, city FROM customers WHERE city = 'Москва'
UNION
SELECT name, city FROM customers WHERE city = 'Казань';

-- UNION ALL сохраняет дубликаты
SELECT city FROM customers
UNION ALL
SELECT city FROM customers;
