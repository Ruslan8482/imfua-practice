-- ============================================================
-- Лабораторная 16: нормализованная схема 3NF, перенос и проверка данных
-- Источник: Normalization.md, разделы 5-9
-- Таблицы создаются пустыми: данные переносятся из orders_bad.
-- ============================================================

USE shop_norm;

-- Повторный запуск: очищаем 3NF-таблицы (порядок важен из-за FK)
DROP TABLE IF EXISTS order_items_3nf;
DROP TABLE IF EXISTS orders_3nf;
DROP TABLE IF EXISTS customers_3nf;
DROP TABLE IF EXISTS products_3nf;

-- ------------------------------------------------------------
-- 5.1. Четыре таблицы в 3NF
-- ------------------------------------------------------------

-- Клиенты
CREATE TABLE customers_3nf (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Товары
CREATE TABLE products_3nf (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    product_price INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Заказы (шапка)
CREATE TABLE orders_3nf (
    order_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date  DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers_3nf(customer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Позиции заказа (строки)
CREATE TABLE order_items_3nf (
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id)   REFERENCES orders_3nf(order_id),
    FOREIGN KEY (product_id) REFERENCES products_3nf(product_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Проверка структуры
SHOW TABLES;
DESCRIBE customers_3nf;
DESCRIBE products_3nf;
DESCRIBE orders_3nf;
DESCRIBE order_items_3nf;

-- ------------------------------------------------------------
-- 6. Перенос данных из orders_bad в 3NF
-- ------------------------------------------------------------

-- 6.1. Клиенты (уникальные пары «имя + город»)
INSERT INTO customers_3nf (customer_name, customer_city)
SELECT DISTINCT customer_name, customer_city
FROM orders_bad;

-- 6.2. Товары (уникальные пары «название + цена»)
INSERT INTO products_3nf (product_name, product_price)
SELECT DISTINCT product_name, product_price
FROM orders_bad;

-- 6.3. Заказы (шапки)
INSERT INTO orders_3nf (order_id, customer_id, order_date)
SELECT o.order_id, c.customer_id, o.order_date
FROM orders_bad o
JOIN customers_3nf c
  ON c.customer_name = o.customer_name
 AND c.customer_city = o.customer_city;

-- 6.4. Позиции заказов
INSERT INTO order_items_3nf (order_id, product_id, quantity)
SELECT o.order_id, p.product_id, o.quantity
FROM orders_bad o
JOIN products_3nf p
  ON p.product_name = o.product_name
 AND p.product_price = o.product_price;

-- 6.5. Что вставилось
SELECT * FROM customers_3nf;
SELECT * FROM products_3nf;
SELECT * FROM orders_3nf;
SELECT * FROM order_items_3nf;

-- ------------------------------------------------------------
-- 7. Проверка корректности переноса
-- ------------------------------------------------------------

-- 7.1. Общая сумма должна совпасть (после удаления order_id = 4: 1200)
SELECT SUM(product_price * quantity) AS total_old
FROM orders_bad;

SELECT SUM(p.product_price * oi.quantity) AS total_new
FROM order_items_3nf oi
JOIN products_3nf p ON oi.product_id = p.product_id;

-- 7.2. Количество заказов, клиентов, товаров
SELECT COUNT(DISTINCT order_id) AS old_count FROM orders_bad;
SELECT COUNT(*) AS new_count FROM orders_3nf;

SELECT COUNT(*) AS old_count FROM
  (SELECT DISTINCT customer_name, customer_city FROM orders_bad) AS t;
SELECT COUNT(*) AS new_count FROM customers_3nf;

SELECT COUNT(*) AS old_count FROM
  (SELECT DISTINCT product_name, product_price FROM orders_bad) AS t;
SELECT COUNT(*) AS new_count FROM products_3nf;

-- 7.3. Сколько потратил Иван (новая схема); должно быть 440
SELECT SUM(p.product_price * oi.quantity) AS total
FROM customers_3nf c
JOIN orders_3nf o       ON c.customer_id = o.customer_id
JOIN order_items_3nf oi ON o.order_id = oi.order_id
JOIN products_3nf p     ON oi.product_id = p.product_id
WHERE c.customer_name = 'Иван';

-- План «после нормализации» для сравнения с EXPLAIN из 02_seed.sql
EXPLAIN SELECT SUM(p.product_price * oi.quantity) AS total
FROM customers_3nf c
JOIN orders_3nf o       ON c.customer_id = o.customer_id
JOIN order_items_3nf oi ON o.order_id = oi.order_id
JOIN products_3nf p     ON oi.product_id = p.product_id
WHERE c.customer_name = 'Иван';

-- ------------------------------------------------------------
-- 8. Повторение операций — аномалии исчезли
-- ------------------------------------------------------------

-- 8.1. Обновление города Ивана: одно UPDATE вместо двух
SELECT * FROM orders_bad WHERE customer_name = 'Иван';

UPDATE customers_3nf SET customer_city = 'Сочи' WHERE customer_name = 'Иван';
SELECT * FROM customers_3nf WHERE customer_name = 'Иван';

-- 8.2. Удаление заказов Марии: клиент остаётся
DELETE FROM order_items_3nf
WHERE order_id IN (
    SELECT o.order_id
    FROM orders_3nf o
    JOIN customers_3nf c ON o.customer_id = c.customer_id
    WHERE c.customer_name = 'Мария'
);

DELETE FROM orders_3nf
WHERE customer_id IN (
    SELECT customer_id FROM customers_3nf WHERE customer_name = 'Мария'
);

SELECT * FROM customers_3nf WHERE customer_name = 'Мария';

-- 8.3. Добавление клиента без заказа — теперь без NULL-полей заказа
INSERT INTO customers_3nf (customer_name, customer_city)
VALUES ('Новый клиент', 'Тверь');

SELECT * FROM customers_3nf WHERE customer_name = 'Новый клиент';

-- ------------------------------------------------------------
-- 9. Убираем «плохую» таблицу безопасным способом (вариант 2 инструкции)
--    Вариант 1: DROP TABLE orders_bad;
-- ------------------------------------------------------------
RENAME TABLE orders_bad TO orders_bad_backup;
SHOW TABLES;

-- 10. Дамп «после нормализации» выполняется commands.sh:
--     artifacts/shop_norm-after-dump.sql
