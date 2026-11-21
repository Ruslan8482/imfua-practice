-- Лабораторная № 2 по нормализации: перенос данных, проверки, аномалии.
-- Выполнять после 01_schema.sql и 02_seed.sql.

USE sales_norm;

-- ===========================================================================
-- 1. Перенос данных в 3NF (INSERT ... SELECT)
-- ===========================================================================

-- Уникальные клиенты
INSERT INTO clients (client_id, client_name, client_city)
SELECT DISTINCT client_id, client_name, client_city
FROM sales_unnormalized;

-- Уникальные товары
INSERT INTO products (product_id, product_name, unit_price)
SELECT DISTINCT product_id, product_name, unit_price
FROM sales_unnormalized;

-- Уникальные продажи (шапки)
INSERT INTO sales (sale_id, sale_date, client_id)
SELECT DISTINCT sale_id, sale_date, client_id
FROM sales_unnormalized;

-- Позиции продаж
INSERT INTO sale_items (sale_id, product_id, quantity)
SELECT sale_id, product_id, quantity
FROM sales_unnormalized;

SELECT * FROM clients;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM sale_items;

-- ===========================================================================
-- 2. Проверка корректности переноса
-- ===========================================================================

-- 2.1. Общая сумма: ожидается 80000.00 в обоих запросах
SELECT SUM(unit_price * quantity) AS total_old
FROM sales_unnormalized;

SELECT SUM(p.unit_price * si.quantity) AS total_new
FROM sale_items si
JOIN products p ON si.product_id = p.product_id;

-- 2.2. Количества (6/6, 3/3, 5/5, 10/10)
SELECT COUNT(DISTINCT sale_id) AS old_sales FROM sales_unnormalized;
SELECT COUNT(*) AS new_sales FROM sales;

SELECT COUNT(*) AS old_clients FROM
    (SELECT DISTINCT client_id FROM sales_unnormalized) AS t;
SELECT COUNT(*) AS new_clients FROM clients;

SELECT COUNT(*) AS old_products FROM
    (SELECT DISTINCT product_id FROM sales_unnormalized) AS t;
SELECT COUNT(*) AS new_products FROM products;

SELECT COUNT(*) AS old_items FROM sales_unnormalized;
SELECT COUNT(*) AS new_items FROM sale_items;

-- 2.3. Сколько потратил клиент с кодом 101? Ожидается 37000.00
SELECT c.client_id, c.client_name,
       SUM(p.unit_price * si.quantity) AS total
FROM clients c
JOIN sales s       ON c.client_id = s.client_id
JOIN sale_items si ON s.sale_id = si.sale_id
JOIN products p    ON si.product_id = p.product_id
WHERE c.client_id = 101
GROUP BY c.client_id, c.client_name;

-- 2.4. Все клиенты и их суммы
SELECT c.client_id, c.client_name,
       SUM(p.unit_price * si.quantity) AS total
FROM clients c
JOIN sales s       ON c.client_id = s.client_id
JOIN sale_items si ON s.sale_id = si.sale_id
JOIN products p    ON si.product_id = p.product_id
GROUP BY c.client_id, c.client_name
ORDER BY c.client_id;

-- ===========================================================================
-- 3. Аномалии и их исчезновение. Изменения отменяются ROLLBACK.
-- ===========================================================================
START TRANSACTION;

-- 3.1. Аномалия обновления: город клиента 101 меняем только в продаже 5001.
UPDATE sales_unnormalized
SET client_city = 'Сочи'
WHERE sale_id = 5001;

SELECT DISTINCT client_id, client_city
FROM sales_unnormalized
WHERE client_id = 101; -- два города у одного клиента

-- В 3NF город меняется в одной строке clients.
UPDATE clients SET client_city = 'Сочи' WHERE client_id = 101;
SELECT client_id, client_name, client_city FROM clients WHERE client_id = 101;

-- 3.2. Аномалия удаления: удаляем все продажи клиента 103.
DELETE FROM sales_unnormalized WHERE sale_id IN (5004, 5006);
SELECT * FROM sales_unnormalized WHERE client_id = 103; -- клиент исчез
SELECT * FROM clients WHERE client_id = 103;            -- а здесь остался

-- В 3NF удаляем позиции и продажи, клиент сохраняется.
DELETE FROM sale_items WHERE sale_id IN (5004, 5006);
DELETE FROM sales WHERE sale_id IN (5004, 5006);
SELECT * FROM clients WHERE client_id = 103;

-- 3.3. Аномалия вставки: клиент без продажи в «плохой» таблице.
INSERT INTO sales_unnormalized (client_id, client_name, client_city)
VALUES (104, 'Новый клиент', 'Тверь');
SELECT * FROM sales_unnormalized WHERE client_id = 104; -- NULL в полях продажи

-- В 3NF клиент добавляется без фиктивной продажи.
INSERT INTO clients (client_id, client_name, client_city)
VALUES (104, 'Новый клиент', 'Тверь');
SELECT * FROM clients WHERE client_id = 104;

ROLLBACK; -- вернули демонстрационные изменения

-- ===========================================================================
-- 4. Удаление старой таблицы после проверок
-- ===========================================================================
DROP TABLE sales_unnormalized;

SHOW TABLES;
