-- Лабораторная № 5 по нормализации: схема.
-- Источник: https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_5.md
-- В оригинале есть только заголовки таблицы; строки — демонстрационные (см. README.md).
-- Правило условия: товары классифицируются по коду товарной классификации.

CREATE DATABASE IF NOT EXISTS orders_class_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE orders_class_norm;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS classifications;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders_class_unnormalized;

-- ---------------------------------------------------------------------------
-- Исходная «плохая» таблица: данные клиента, товара и класса
-- дублируются в каждой строке позиции заказа.
-- ---------------------------------------------------------------------------
CREATE TABLE orders_class_unnormalized (
    order_id   INT,
    order_date DATE,
    client_id  INT,
    client_name VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    price      DECIMAL(10,2),
    class_id   INT,
    class_name VARCHAR(100),
    quantity   INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Пять таблиц в 3NF. Создаются пустыми: данные переносятся в 03_queries.sql.
-- ---------------------------------------------------------------------------

-- 1. Клиенты
CREATE TABLE customers (
    client_id   INT NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Товарные классификации
CREATE TABLE classifications (
    class_id   INT NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Товары: class_id хранится один раз на товар
CREATE TABLE products (
    product_id   INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    class_id     INT NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_products_class FOREIGN KEY (class_id)
        REFERENCES classifications (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Шапки заказов
CREATE TABLE orders (
    order_id   INT NOT NULL,
    order_date DATE NOT NULL,
    client_id  INT NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (client_id)
        REFERENCES customers (client_id)
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
