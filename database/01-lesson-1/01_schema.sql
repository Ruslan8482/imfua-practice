-- ============================================================
-- Лабораторная 01: SQL-команды для создания и заполнения
-- нормализованных таблиц (оригинал: Lesson_1.md).
-- Шаг 1: база данных sales и четыре таблицы.
-- Порядок: customers -> products -> reports -> report_items
-- (от независимых таблиц к зависимым, чтобы не нарушить внешние ключи).
-- ============================================================

CREATE DATABASE sales
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sales;

-- 1. Покупатели
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Товары
CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price        INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3. Отчёты (ссылка на customers)
CREATE TABLE reports (
    report_id   INT PRIMARY KEY,
    report_date DATE NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 4. Реализованные товары (ссылки на reports и products)
CREATE TABLE report_items (
    report_id  INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    PRIMARY KEY (report_id, product_id),
    FOREIGN KEY (report_id)  REFERENCES reports(report_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SHOW TABLES;
