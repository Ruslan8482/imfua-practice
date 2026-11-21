-- Лабораторная № 4 по нормализации: перенос данных, проверки, аномалии.
-- Выполнять после 01_schema.sql и 02_seed.sql.

USE orders_rep_norm;

-- ===========================================================================
-- 1. Перенос данных в 3NF (INSERT ... SELECT)
-- ===========================================================================

-- Уникальные коды клиентов
INSERT INTO clients (client_id)
SELECT DISTINCT client_id
FROM orders_rep_unnormalized;

-- Уникальные представители
INSERT INTO representatives (rep_id, rep_name)
SELECT DISTINCT rep_id, rep_name
FROM orders_rep_unnormalized;

-- Уникальные товары
INSERT INTO products (product_id, product_name, price)
SELECT DISTINCT product_id, product_name, price
FROM orders_rep_unnormalized;

-- Шапки заказов: rep_id берётся один на заказ
INSERT INTO orders (order_id, order_date, client_id, rep_id)
SELECT DISTINCT order_id, order_date, client_id, rep_id
FROM orders_rep_unnormalized;

-- Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity)
SELECT order_id, product_id, quantity
FROM orders_rep_unnormalized;

SELECT * FROM clients;
SELECT * FROM representatives;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- ===========================================================================
-- 2. Проверка корректности переноса
-- ===========================================================================

-- 2.1. Общая сумма: ожидается 66500.00 в обоих запросах
SELECT SUM(price * quantity) AS total_old
FROM orders_rep_unnormalized;

SELECT SUM(p.price * oi.quantity) AS total_new
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

-- 2.2. Количества (4/4, 3/3, 5/5, 3/3, 7/7)
SELECT COUNT(DISTINCT order_id) AS old_orders FROM orders_rep_unnormalized;
SELECT COUNT(*) AS new_orders FROM orders;

SELECT COUNT(*) AS old_clients FROM
    (SELECT DISTINCT client_id FROM orders_rep_unnormalized) AS t;
SELECT COUNT(*) AS new_clients FROM clients;

SELECT COUNT(*) AS old_products FROM
    (SELECT DISTINCT product_id FROM orders_rep_unnormalized) AS t;
SELECT COUNT(*) AS new_products FROM products;

SELECT COUNT(*) AS old_reps FROM
    (SELECT DISTINCT rep_id FROM orders_rep_unnormalized) AS t;
SELECT COUNT(*) AS new_reps FROM representatives;

SELECT COUNT(*) AS old_items FROM orders_rep_unnormalized;
SELECT COUNT(*) AS new_items FROM order_items;

-- 2.3. Сколько потратил клиент 301? Ожидается 40500.00
SELECT o.client_id,
       SUM(p.price * oi.quantity) AS total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE o.client_id = 301
GROUP BY o.client_id;

-- 2.4. Правило «один заказ — один представитель»: везде должно быть 1
SELECT o.order_id, COUNT(DISTINCT o.rep_id) AS reps_per_order
FROM orders o
GROUP BY o.order_id
ORDER BY o.order_id;

-- ===========================================================================
-- 3. Аномалии и их исчезновение. Изменения отменяются ROLLBACK.
-- ===========================================================================
START TRANSACTION;

-- 3.1. Аномалия обновления: имя представителя меняем только в одной строке заказа 6001.
UPDATE orders_rep_unnormalized
SET rep_name = 'Петрова Мария'
WHERE order_id = 6001 AND product_id = 401;

SELECT order_id, rep_id, rep_name
FROM orders_rep_unnormalized
WHERE order_id = 6001; -- у одного заказа два разных представителя

-- В 3NF имя меняется в одной строке representatives.
UPDATE representatives SET rep_name = 'Петрова Мария' WHERE rep_id = 901;
SELECT * FROM representatives WHERE rep_id = 901;
SELECT o.order_id, r.rep_id, r.rep_name
FROM orders o JOIN representatives r ON o.rep_id = r.rep_id
WHERE o.order_id = 6001;

-- 3.2. Аномалия удаления: удаляем все позиции заказа 6004.
DELETE FROM orders_rep_unnormalized WHERE order_id = 6004;
SELECT * FROM orders_rep_unnormalized WHERE client_id = 303; -- клиент исчез
SELECT * FROM clients WHERE client_id = 303;                 -- а здесь остался
SELECT * FROM representatives WHERE rep_id = 903;            -- представитель остался

-- В 3NF удаляем позиции и заказ, клиент и представитель сохраняются.
DELETE FROM order_items WHERE order_id = 6004;
DELETE FROM orders WHERE order_id = 6004;
SELECT * FROM clients WHERE client_id = 303;

-- 3.3. Аномалия вставки: представитель без заказа в «плохой» таблице.
INSERT INTO orders_rep_unnormalized (rep_id, rep_name)
VALUES (904, 'Новый представитель');
SELECT * FROM orders_rep_unnormalized WHERE rep_id = 904; -- NULL в полях заказа

-- В 3NF представитель добавляется отдельно.
INSERT INTO representatives (rep_id, rep_name)
VALUES (904, 'Новый представитель');
SELECT * FROM representatives WHERE rep_id = 904;

ROLLBACK; -- вернули демонстрационные изменения

-- ===========================================================================
-- 4. Удаление старой таблицы после проверок
-- ===========================================================================
DROP TABLE orders_rep_unnormalized;

SHOW TABLES;
