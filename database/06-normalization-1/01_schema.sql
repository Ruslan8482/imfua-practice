-- Повторно запускаемый прогон: чистая БД для этой лабораторной.
DROP DATABASE IF EXISTS sales_norm;

-- Лабораторная № 1 по нормализации: схема.
-- Источник: https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_1.md
-- Порядок: 01_schema.sql -> 02_seed.sql -> 03_queries.sql

CREATE DATABASE IF NOT EXISTS sales_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sales_norm;

-- Повторный запуск: сначала удаляем зависимые таблицы, затем остальные.
DROP TABLE IF EXISTS report_items;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sales_unnormalized_2;

-- ---------------------------------------------------------------------------
-- Исходная «плохая» таблица (структура строго по инструкции).
-- Исходные строки загружаются отдельно в 02_seed.sql:
--
-- INSERT INTO sales_unnormalized_2 VALUES
-- (1101, '2026-03-05', 12, 'Дания',   101, 'Дыни',      800, 1100),
-- (1101, '2026-03-05', 12, 'Дания',   102, 'Клубника',  150,  300),
-- (1102, '2026-03-07', 23, 'Испания', 103, 'Яблоки',    120, 1700),
-- (1103, '2026-03-08', 25, 'Албания', 104, 'Лимоны',    200,  500),
-- (1104, '2026-03-10', 12, 'Дания',   101, 'Дыни',      800, 2500),
-- (1105, '2026-03-12', 25, 'Албания', 103, 'Яблоки',    120, 2000),
-- (1105, '2026-03-12', 25, 'Албания', 104, 'Лимоны',    200,  700);
-- ---------------------------------------------------------------------------
CREATE TABLE sales_unnormalized_2 (
    report_id     INT,
    report_date   DATE,
    customer_id   INT,
    customer_name VARCHAR(100),
    product_id    INT,
    product_name  VARCHAR(100),
    price         DECIMAL(10,2),
    quantity      INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Четыре таблицы в 3NF. Создаются пустыми: данные переносятся в 03_queries.sql.
-- ---------------------------------------------------------------------------

-- 1. Покупатели
CREATE TABLE customers (
    customer_id   INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Товары
CREATE TABLE products (
    product_id   INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Шапки отчётов
CREATE TABLE reports (
    report_id   INT NOT NULL,
    report_date DATE NOT NULL,
    customer_id INT NOT NULL,
    PRIMARY KEY (report_id),
    CONSTRAINT fk_reports_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Позиции отчётов
CREATE TABLE report_items (
    report_id  INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    PRIMARY KEY (report_id, product_id),
    CONSTRAINT fk_items_report  FOREIGN KEY (report_id)
        REFERENCES reports (report_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
