-- Лабораторная № 5 по нормализации: перенос данных, проверки, аномалии.
-- Выполнять после 01_schema.sql и 02_seed.sql.

USE orders_class_norm;

-- ===========================================================================
-- 1. Перенос данных в 3NF (INSERT ... SELECT)
-- ===========================================================================

-- Уникальные клиенты
INSERT INTO customers (client_id, client_name)
SELECT DISTINCT client_id, client_name
FROM orders_class_unnormalized;

-- Уникальные товарные классификации
INSERT INTO classifications (class_id, class_name)
SELECT DISTINCT class_id, class_name
FROM orders_class_unnormalized;

-- Уникальные товары вместе с кодом класса
INSERT INTO products (product_id, product_name, price, class_id)
SELECT DISTINCT product_id, product_name, price, class_id
FROM orders_class_unnormalized;

-- Шапки заказов
INSERT INTO orders (order_id, order_date, client_id)
SELECT DISTINCT order_id, order_date, client_id
FROM orders_class_unnormalized;

-- Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity)
SELECT order_id, product_id, quantity
FROM orders_class_unnormalized;

SELECT * FROM customers;
SELECT * FROM classifications;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- ===========================================================================
-- 2. Проверка корректности переноса
-- ===========================================================================

-- 2.1. Общая сумма: ожидается 70000.00 в обоих запросах
SELECT SUM(price * quantity) AS total_old
FROM orders_class_unnormalized;

SELECT SUM(p.price * oi.quantity) AS total_new
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

-- 2.2. Количества (4/4, 3/3, 5/5, 2/2, 6/6)
SELECT COUNT(DISTINCT order_id) AS old_orders FROM orders_class_unnormalized;
SELECT COUNT(*) AS new_orders FROM orders;

SELECT COUNT(*) AS old_customers FROM
    (SELECT DISTINCT client_id FROM orders_class_unnormalized) AS t;
SELECT COUNT(*) AS new_customers FROM customers;

SELECT COUNT(*) AS old_products FROM
    (SELECT DISTINCT product_id FROM orders_class_unnormalized) AS t;
SELECT COUNT(*) AS new_products FROM products;

SELECT COUNT(*) AS old_classes FROM
    (SELECT DISTINCT class_id FROM orders_class_unnormalized) AS t;
SELECT COUNT(*) AS new_classes FROM classifications;

SELECT COUNT(*) AS old_items FROM orders_class_unnormalized;
SELECT COUNT(*) AS new_items FROM order_items;

-- 2.3. Сколько потратил клиент 801? Ожидается 47000.00
SELECT c.client_id, c.client_name,
       SUM(p.price * oi.quantity) AS total
FROM customers c
JOIN orders o       ON c.client_id = o.client_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE c.client_id = 801
GROUP BY c.client_id, c.client_name;

-- 2.4. Суммы по товарным классам (Электроника — 40000.00, Мебель — 30000.00)
SELECT cl.class_id, cl.class_name,
       SUM(p.price * oi.quantity) AS total
FROM classifications cl
JOIN products p     ON cl.class_id = p.class_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY cl.class_id, cl.class_name
ORDER BY cl.class_id;

-- ===========================================================================
-- 3. Аномалии и их исчезновение. Изменения отменяются ROLLBACK.
-- ===========================================================================
START TRANSACTION;

-- 3.1. Аномалия обновления: переименовали класс 1 только в одной строке.
UPDATE orders_class_unnormalized
SET class_name = 'Бытовая техника'
WHERE order_id = 7001 AND product_id = 401;

SELECT DISTINCT class_id, class_name
FROM orders_class_unnormalized
WHERE class_id = 1; -- два названия у одного класса

-- В 3NF название меняется в одной строке classifications.
UPDATE classifications SET class_name = 'Бытовая техника' WHERE class_id = 1;
SELECT * FROM classifications WHERE class_id = 1;

-- 3.2. Аномалия удаления: удаляем все заказы клиента 801.
DELETE FROM orders_class_unnormalized WHERE client_id = 801;
SELECT * FROM orders_class_unnormalized WHERE client_id = 801; -- клиент исчез
SELECT * FROM customers WHERE client_id = 801;                 -- а здесь остался

-- В 3NF удаляем позиции и заказы; клиент, товары и классы остаются.
DELETE FROM order_items WHERE order_id IN (7001, 7003);
DELETE FROM orders WHERE order_id IN (7001, 7003);
SELECT * FROM customers WHERE client_id = 801;
SELECT * FROM products WHERE class_id = 1;
SELECT * FROM classifications;

-- 3.3. Аномалия вставки: класс без товаров в «плохой» таблице.
INSERT INTO orders_class_unnormalized (class_id, class_name)
VALUES (3, 'Одежда');
SELECT * FROM orders_class_unnormalized WHERE class_id = 3; -- NULL в полях заказа/товара

-- В 3NF класс добавляется отдельно.
INSERT INTO classifications (class_id, class_name)
VALUES (3, 'Одежда');
SELECT * FROM classifications WHERE class_id = 3;

ROLLBACK; -- вернули демонстрационные изменения

-- ===========================================================================
-- 4. Удаление старой таблицы после проверок
-- ===========================================================================
DROP TABLE orders_class_unnormalized;

SHOW TABLES;
