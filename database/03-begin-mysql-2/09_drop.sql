-- ============================================================
-- Лабораторная 03, шаг 13: удаление таблиц и базы.
-- Выполнять ТОЛЬКО после дампа (шаг 12.3)!
-- ============================================================

USE sql_practice;

DROP TABLE orders;
SHOW TABLES;

DROP TABLE customers;
SHOW TABLES;

DROP DATABASE sql_practice;

-- VIEW my_actions исчезнет вместе с БД sql_practice
SHOW DATABASES;
