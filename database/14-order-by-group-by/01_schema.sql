-- ============================================================
-- Лабораторная 14: ускорение ORDER BY / GROUP BY
-- Источник: ORDER_BY_GROUP_BY.md, раздел 2
-- ============================================================

CREATE DATABASE sort_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sort_practice;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'new',
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    INDEX idx_customer (customer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
