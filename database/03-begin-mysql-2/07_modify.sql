-- ============================================================
-- Лабораторная 03, шаги 9-11: UPDATE, DELETE и ALTER TABLE.
-- ============================================================

USE sql_practice;

-- ---------- Шаг 9: обновление данных ----------
UPDATE customers SET city = 'Екатеринбург' WHERE id = 4;
UPDATE orders SET status = 'paid' WHERE id = 3;

SELECT * FROM customers WHERE id = 4;
SELECT * FROM orders WHERE id = 3;

-- Всегда указывайте WHERE:
-- UPDATE customers SET city = 'X';  -- обновило бы ВСЕ строки

-- ---------- Шаг 10: удаление данных ----------
DELETE FROM orders WHERE id = 6;
-- Без WHERE удалились бы все строки: DELETE FROM orders;
SELECT * FROM orders;

-- ---------- Шаг 11: изменение структуры ----------
-- Добавить столбец
ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
SELECT * FROM customers;

UPDATE customers SET phone = '123-36-77' WHERE id = 4;
SELECT * FROM customers WHERE id = 4;
SELECT * FROM customers;

-- Изменить тип столбца
ALTER TABLE customers MODIFY COLUMN phone VARCHAR(30);

-- Удалить столбец
ALTER TABLE customers DROP COLUMN phone;
SELECT * FROM customers;
