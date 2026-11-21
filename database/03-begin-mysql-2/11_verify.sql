-- ============================================================
-- Лабораторная 03, шаг 14.5: проверка восстановленной БД.
-- Выполнять ПОСЛЕ импорта дампа:
-- docker exec -i my-mysql mysql -uroot -p123 sql_practice < dump_clean.sql
-- ============================================================

USE sql_practice;
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM my_actions LIMIT 5;
