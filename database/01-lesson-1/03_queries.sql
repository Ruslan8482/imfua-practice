-- ============================================================
-- Лабораторная 01: проверка данных и восстановление «плоской»
-- (ненормализованной) таблицы запросом с JOIN.
-- ============================================================

USE sales;

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM reports;
SELECT * FROM report_items;

-- Запрос восстанавливает исходную ненормализованную таблицу:
-- 7 строк, report_id от 1101 до 1105.
SELECT r.report_id, r.report_date, c.customer_name,
       p.product_name, p.price, ri.quantity
FROM reports r
JOIN customers c   ON r.customer_id = c.customer_id
JOIN report_items ri ON r.report_id = ri.report_id
JOIN products p    ON ri.product_id = p.product_id
ORDER BY r.report_id, p.product_id;
