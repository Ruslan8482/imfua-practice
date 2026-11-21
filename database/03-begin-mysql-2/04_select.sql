-- ============================================================
-- Лабораторная 03, шаг 4: выборка данных (SELECT).
-- ============================================================

USE sql_practice;

-- 4.1. Все столбцы и все строки
SELECT * FROM customers;

-- 4.2. Только нужные столбцы
SELECT name, city FROM customers;

-- 4.3. Условие WHERE
SELECT * FROM customers WHERE city = 'Москва';
SELECT * FROM orders WHERE amount > 1000;
SELECT * FROM orders WHERE status = 'paid' AND amount > 1500;
SELECT * FROM orders WHERE status = 'new' OR status = 'cancelled';

-- 4.4. Сортировка ORDER BY
SELECT * FROM customers ORDER BY name;
SELECT * FROM orders ORDER BY amount DESC;
SELECT * FROM orders ORDER BY order_date DESC, amount ASC;

-- 4.5. Ограничение количества строк LIMIT
SELECT * FROM orders ORDER BY amount DESC LIMIT 3;

-- 4.6. Поиск по шаблону LIKE
SELECT * FROM customers WHERE name LIKE 'И%';      -- начинается на И
SELECT * FROM customers WHERE email LIKE '%@example.com';

-- 4.7. Диапазон BETWEEN и список IN
SELECT * FROM orders WHERE amount BETWEEN 1000 AND 3000;
SELECT * FROM customers WHERE city IN ('Москва', 'Казань');
-- IN — сокращённая форма цепочки OR, результат тот же:
SELECT * FROM customers WHERE city = 'Москва' OR city = 'Казань';

-- 4.8. Пустые значения IS NULL
SELECT * FROM customers WHERE city IS NULL;
