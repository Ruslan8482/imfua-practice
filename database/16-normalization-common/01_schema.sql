-- ============================================================
-- Лабораторная 16: нормализация — аномалии → 3NF
-- Источник: Normalization.md, раздел 2.1-2.2
-- ============================================================

CREATE DATABASE shop_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE shop_norm;

SHOW DATABASES;

-- «Плохая» таблица: клиент, товар и заказ смешаны в одной строке
CREATE TABLE orders_bad (
    order_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    product_name  VARCHAR(100),
    product_price INT,
    quantity      INT,
    order_date    DATE
);
