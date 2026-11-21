-- ============================================================
-- Лабораторная 05, разделы 11-12: WITH CHECK OPTION и права через VIEW.
-- ============================================================

USE sql_practice;

-- ---------- 11. WITH CHECK OPTION ----------
-- Пересоздаём VIEW с email (обязательный столбец)
CREATE OR REPLACE VIEW moscow_customers AS
SELECT id, name, email, city
FROM customers
WHERE city = 'Москва';

-- Вставляем клиента из Казани с уникальным email
INSERT INTO moscow_customers (name, email, city)
VALUES ('Пётр Второй', 'petr2@example.com', 'Казань');

-- Строка есть в customers, но не видна через VIEW
SELECT * FROM customers WHERE email = 'petr2@example.com';
SELECT * FROM moscow_customers;

-- С WITH CHECK OPTION такая вставка запрещена
CREATE OR REPLACE VIEW moscow_customers AS
SELECT id, name, email, city
FROM customers
WHERE city = 'Москва'
WITH CHECK OPTION;

-- Ожидаемая ошибка (запрос закомментирован):
-- INSERT INTO moscow_customers (name, email, city)
-- VALUES ('Пётр Третий', 'petr3@example.com', 'Казань');
-- ERROR 1369 (HY000): CHECK OPTION failed 'sql_practice.moscow_customers'

-- Убираем «лишние» строки перед следующими разделами
DELETE FROM customers WHERE email IN ('petr2@example.com', 'petr3@example.com');
-- Либо вернуть исходное состояние целиком: DELETE FROM customers WHERE id > 5;

-- ---------- 12. Права доступа через VIEW ----------
CREATE VIEW public_customers AS
SELECT id, name, city FROM customers;   -- без email

CREATE USER IF NOT EXISTS 'analyst'@'%' IDENTIFIED BY 'pass';
GRANT SELECT ON sql_practice.public_customers TO 'analyst'@'%';
-- Права на саму таблицу customers не выдаём: analyst видит только VIEW без email.

SELECT * FROM public_customers;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
