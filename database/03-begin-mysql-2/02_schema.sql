-- ============================================================
-- Лабораторная 03, шаг 2: связанные таблицы customers и orders.
-- ============================================================

USE sql_practice;

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'new',
    FOREIGN KEY (customer_id) REFERENCES customers(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SHOW TABLES;                -- в списке будет и VIEW my_actions

DESCRIBE customers;
DESCRIBE orders;

-- CREATE TABLE customers создаёт файл customers.ibd (InnoDB).
-- Проверить вне клиента: docker exec -it my-mysql ls -la /var/lib/mysql/sql_practice
