-- Лабораторная № 1 по нормализации: перенос данных, проверки, аномалии.
-- Выполнять после 01_schema.sql и 02_seed.sql.

USE sales_norm;

-- ===========================================================================
-- 1. Перенос данных из sales_unnormalized_2 в 3NF (INSERT ... SELECT)
-- ===========================================================================

-- Уникальные покупатели
INSERT INTO customers (customer_id, customer_name)
SELECT DISTINCT customer_id, customer_name
FROM sales_unnormalized_2;

-- Уникальные товары
INSERT INTO products (product_id, product_name, price)
SELECT DISTINCT product_id, product_name, price
FROM sales_unnormalized_2;

-- Уникальные отчёты (шапки)
INSERT INTO reports (report_id, report_date, customer_id)
SELECT DISTINCT report_id, report_date, customer_id
FROM sales_unnormalized_2;

-- Позиции отчётов: report_id и product_id уже есть в исходной таблице
INSERT INTO report_items (report_id, product_id, quantity)
SELECT report_id, product_id, quantity
FROM sales_unnormalized_2;

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM reports;
SELECT * FROM report_items;

-- ===========================================================================
-- 2. Проверка корректности переноса
-- ===========================================================================

-- 2.1. Общая сумма: ожидается 3609000.00 в обоих запросах
SELECT SUM(price * quantity) AS total_old
FROM sales_unnormalized_2;

SELECT SUM(p.price * ri.quantity) AS total_new
FROM report_items ri
JOIN products p ON ri.product_id = p.product_id;

-- 2.2. Количество отчётов, покупателей, товаров и позиций (5/5, 3/3, 4/4, 7/7)
SELECT COUNT(DISTINCT report_id) AS old_reports FROM sales_unnormalized_2;
SELECT COUNT(*) AS new_reports FROM reports;

SELECT COUNT(*) AS old_customers FROM
    (SELECT DISTINCT customer_id FROM sales_unnormalized_2) AS t;
SELECT COUNT(*) AS new_customers FROM customers;

SELECT COUNT(*) AS old_products FROM
    (SELECT DISTINCT product_id FROM sales_unnormalized_2) AS t;
SELECT COUNT(*) AS new_products FROM products;

SELECT COUNT(*) AS old_items FROM sales_unnormalized_2;
SELECT COUNT(*) AS new_items FROM report_items;

-- 2.3. Сколько потратил покупатель с кодом 12? Ожидается 2925000.00
SELECT c.customer_id, c.customer_name,
       SUM(p.price * ri.quantity) AS total
FROM customers c
JOIN reports r           ON c.customer_id = r.customer_id
JOIN report_items ri     ON r.report_id = ri.report_id
JOIN products p          ON ri.product_id = p.product_id
WHERE c.customer_id = 12
GROUP BY c.customer_id, c.customer_name;

-- 2.4. Все покупатели и их суммы
SELECT c.customer_id, c.customer_name,
       SUM(p.price * ri.quantity) AS total
FROM customers c
JOIN reports r       ON c.customer_id = r.customer_id
JOIN report_items ri ON r.report_id = ri.report_id
JOIN products p      ON ri.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- ===========================================================================
-- 3. Аномалии «плохой» таблицы и исчезновение аномалий в 3NF.
--    Все изменения демонстрационные и отменяются ROLLBACK.
-- ===========================================================================
START TRANSACTION;

-- 3.1. Аномалия обновления: имя покупателя 12 меняем только в отчёте 1101.
UPDATE sales_unnormalized_2
SET customer_name = 'Дания (новое имя)'
WHERE report_id = 1101;

-- Один и тот же покупатель теперь имеет два разных имени.
SELECT DISTINCT customer_id, customer_name
FROM sales_unnormalized_2
WHERE customer_id = 12;

-- В 3NF имя хранится в одной строке: достаточно одного UPDATE.
UPDATE customers SET customer_name = 'Дания (новое имя)' WHERE customer_id = 12;
SELECT customer_id, customer_name FROM customers WHERE customer_id = 12;

-- 3.2. Аномалия удаления: удаляем все отчёты покупателя 12.
DELETE FROM sales_unnormalized_2 WHERE report_id IN (1101, 1104);
SELECT * FROM sales_unnormalized_2 WHERE customer_id = 12; -- покупатель исчез
SELECT * FROM customers WHERE customer_id = 12;            -- а здесь остался

-- В 3NF удаляем позиции и отчёты, покупатель сохраняется.
DELETE FROM report_items WHERE report_id IN (1101, 1104);
DELETE FROM reports WHERE report_id IN (1101, 1104);
SELECT * FROM customers WHERE customer_id = 12;

-- 3.3. Аномалия вставки: покупатель без отчёта в «плохой» таблице.
INSERT INTO sales_unnormalized_2 (customer_id, customer_name)
VALUES (99, 'Новый покупатель');
SELECT * FROM sales_unnormalized_2 WHERE customer_id = 99; -- NULL в полях отчёта

-- В 3NF покупатель добавляется без фиктивного отчёта.
INSERT INTO customers (customer_id, customer_name)
VALUES (99, 'Новый покупатель');
SELECT * FROM customers WHERE customer_id = 99;

ROLLBACK; -- вернули демонстрационные изменения

-- ===========================================================================
-- 4. Удаление старой таблицы только после успешных проверок
-- ===========================================================================
DROP TABLE sales_unnormalized_2;

SHOW TABLES;
