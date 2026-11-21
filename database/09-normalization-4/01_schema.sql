-- Лабораторная № 4 по нормализации: схема.
-- Источник: https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_4.md
-- В оригинале есть только заголовки таблицы; строки — демонстрационные (см. README.md).
-- Правило условия: один код заказа соответствует только одному представителю.

CREATE DATABASE IF NOT EXISTS orders_rep_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE orders_rep_norm;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS representatives;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS orders_rep_unnormalized;

-- ---------------------------------------------------------------------------
-- Исходная «плохая» таблица: данные клиента, товара и представителя
-- дублируются в каждой строке позиции заказа.
-- ---------------------------------------------------------------------------
CREATE TABLE orders_rep_unnormalized (
    order_id         INT,
    order_date       DATE,
    client_id        INT,
    product_id       INT,
    product_name     VARCHAR(100),
    price            DECIMAL(10,2),
    rep_id           INT,
    rep_name         VARCHAR(100),
    quantity         INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Пять таблиц в 3NF. Создаются пустыми: данные переносятся в 03_queries.sql.
-- ---------------------------------------------------------------------------

-- 1. Клиенты (в заголовках оригинала есть только код клиента)
CREATE TABLE clients (
    client_id INT NOT NULL,
    PRIMARY KEY (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Представители
CREATE TABLE representatives (
    rep_id   INT NOT NULL,
    rep_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (rep_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Товары
CREATE TABLE products (
    product_id   INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Шапки заказов: представитель хранится один раз на заказ
CREATE TABLE orders (
    order_id   INT NOT NULL,
    order_date DATE NOT NULL,
    client_id  INT NOT NULL,
    rep_id     INT NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_client FOREIGN KEY (client_id)
        REFERENCES clients (client_id),
    CONSTRAINT fk_orders_rep FOREIGN KEY (rep_id)
        REFERENCES representatives (rep_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Позиции заказов
CREATE TABLE order_items (
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
