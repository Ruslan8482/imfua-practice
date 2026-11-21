-- ============================================================
-- Лабораторная 05, разделы 4-10: простые VIEW, VIEW с JOIN/агрегацией,
-- просмотр определений, изменение/удаление, обновляемые VIEW,
-- производительность (EXPLAIN).
-- ============================================================

USE sql_practice;

-- ---------- 4. Простейшее представление ----------
-- Без VIEW: SELECT * FROM customers WHERE city = 'Москва';
CREATE VIEW moscow_customers AS
SELECT id, name, email
FROM customers
WHERE city = 'Москва';

SELECT * FROM moscow_customers;
-- Ожидается: 1 Иван Иванов, 3 Мария Сидорова.
-- Данные не копируются: VIEW заново выполняет запрос при каждом обращении.

-- ---------- 5. VIEW с JOIN и агрегацией ----------
CREATE VIEW customer_summary AS
SELECT c.id,
       c.name,
       c.city,
       COUNT(o.id)              AS order_count,
       COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.city;

SELECT * FROM customer_summary ORDER BY total_amount DESC;
SELECT name, total_amount FROM customer_summary WHERE total_amount > 2000;

-- Проверка плана из раздела 10 для исходного определения VIEW:
EXPLAIN SELECT * FROM customer_summary WHERE city = 'Москва';

-- ---------- 6. VIEW с фильтрацией внутри ----------
SELECT * FROM customer_summary WHERE city = 'Москва';

-- ---------- 7. Просмотр существующих VIEW ----------
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SHOW TABLES;
-- Интерактивно: SHOW CREATE VIEW customer_summary\G
SHOW CREATE VIEW customer_summary;

-- ---------- 8. Изменение и удаление VIEW ----------
SELECT * FROM moscow_customers;

CREATE OR REPLACE VIEW moscow_customers AS
SELECT id, name, email, created_at
FROM customers
WHERE city = 'Москва';

SELECT * FROM moscow_customers;

DROP VIEW moscow_customers;
DROP VIEW IF EXISTS moscow_customers;
SHOW TABLES;

-- ---------- 9. Обновляемые VIEW ----------
CREATE VIEW active_customers AS
SELECT id, name, email, city
FROM customers
WHERE city IS NOT NULL;

UPDATE active_customers SET city = 'Сочи' WHERE id = 2;
SELECT * FROM customers WHERE id = 2;

INSERT INTO active_customers (name, email, city)
VALUES ('Новый Клиент', 'new@example.com', 'Уфа');

DELETE FROM active_customers WHERE id = 6;
SELECT * FROM customers;

-- Необновляемое VIEW (CREATE OR REPLACE перезаписывает customer_summary):
CREATE OR REPLACE VIEW customer_summary AS
SELECT c.id, c.name, COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- Ожидаемая ошибка при попытке обновления (поэтому запрос закомментирован):
-- UPDATE customer_summary SET name = 'X' WHERE id = 1;
-- ERROR 1288 (HY000): The target table customer_summary of the UPDATE is not updatable
-- Причина: COUNT(o.id) — агрегат, MySQL не может сопоставить строку VIEW со строкой таблицы.

-- ---------- 10. VIEW и производительность ----------
-- Точный запрос инструкции для исходного определения customer_summary:
-- EXPLAIN SELECT * FROM customer_summary WHERE city = 'Москва';
-- (после переопределения в разделе 9 столбца city в VIEW нет, поэтому
--  проверка плана для исходного определения выполняется до него, здесь —
--  для текущего определения). Для текущего определения:
EXPLAIN SELECT * FROM customer_summary;
-- VIEW не материализован: он не хранит данные и не имеет индексов;
-- при каждом обращении выполняется весь запрос заново.
