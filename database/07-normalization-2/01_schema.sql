-- Лабораторная № 2 по нормализации: схема.
-- Источник: https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_2.md
-- Порядок: 01_schema.sql -> 02_seed.sql -> 03_queries.sql

CREATE DATABASE IF NOT EXISTS sales_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sales_norm;

DROP TABLE IF EXISTS sale_items;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS sales_unnormalized;

-- ---------------------------------------------------------------------------
-- Исходная «плохая» таблица (структура строго по инструкции).
-- Исходные строки загружаются отдельно в 02_seed.sql:
--
-- INSERT INTO sales_unnormalized VALUES
-- (5001, '2026-11-01', 101, 'Иванов Иван',     'Москва',           201, 'Монитор',    15000.00, 2),
-- (5001, '2026-11-01', 101, 'Иванов Иван',     'Москва',           202, 'Клавиатура',  2000.00, 1),
-- (5002, '2026-11-02', 102, 'Петрова Мария',   'Санкт-Петербург', 203, 'Мышь',        1000.00, 3),
-- (5002, '2026-11-02', 102, 'Петрова Мария',   'Санкт-Петербург', 204, 'Наушники',    3500.00, 1),
-- (5003, '2026-11-03', 101, 'Иванов Иван',     'Москва',           205, 'Колонки',     2500.00, 2),
-- (5004, '2026-11-04', 103, 'Сидоров Алексей', 'Казань',           202, 'Клавиатура',  2000.00, 5),
-- (5004, '2026-11-04', 103, 'Сидоров Алексей', 'Казань',           203, 'Мышь',        1000.00, 2),
-- (5005, '2026-11-05', 102, 'Петрова Мария',   'Санкт-Петербург', 201, 'Монитор',    15000.00, 1),
-- (5006, '2026-11-06', 103, 'Сидоров Алексей', 'Казань',           204, 'Наушники',    3500.00, 2),
-- (5006, '2026-11-06', 103, 'Сидоров Алексей', 'Казань',           205, 'Колонки',     2500.00, 1);
-- ---------------------------------------------------------------------------
CREATE TABLE sales_unnormalized (
    sale_id       INT,
    sale_date     DATE,
    client_id     INT,
    client_name   VARCHAR(100),
    client_city   VARCHAR(100),
    product_id    INT,
    product_name  VARCHAR(100),
    unit_price    DECIMAL(10,2),
    quantity      INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Четыре таблицы в 3NF. Создаются пустыми: данные переносятся в 03_queries.sql.
-- ---------------------------------------------------------------------------

-- 1. Клиенты
CREATE TABLE clients (
    client_id   INT NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    client_city VARCHAR(100) NOT NULL,
    PRIMARY KEY (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Товары
CREATE TABLE products (
    product_id   INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Шапки продаж
CREATE TABLE sales (
    sale_id    INT NOT NULL,
    sale_date  DATE NOT NULL,
    client_id  INT NOT NULL,
    PRIMARY KEY (sale_id),
    CONSTRAINT fk_sales_client FOREIGN KEY (client_id)
        REFERENCES clients (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Позиции продаж
CREATE TABLE sale_items (
    sale_id    INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    PRIMARY KEY (sale_id, product_id),
    CONSTRAINT fk_items_sale    FOREIGN KEY (sale_id)
        REFERENCES sales (sale_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
