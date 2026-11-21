-- ============================================================
-- Лабораторная 15: индексы и JOIN
-- Источник: Index_JOIN.md, раздел 2
-- ВАЖНО: на orders.user_id намеренно НЕТ внешнего ключа и НЕТ индекса —
--        это нужно для эксперимента 1 «JOIN без индекса».
-- ============================================================

CREATE DATABASE join_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE join_practice;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    vip_level INT DEFAULT 0
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'new'
    -- ВНИМАНИЕ: здесь НЕТ внешнего ключа и НЕТ индекса на user_id
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
