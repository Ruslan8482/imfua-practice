-- ============================================================
-- Лабораторная 02, шаг 6: обновление и просмотр данных.
-- ============================================================

USE my_database;

UPDATE users SET name = 'Иван Петров' WHERE id = 1;
UPDATE users SET name = 'Vasya' WHERE id = 1;

SELECT * FROM users;
SELECT * FROM users WHERE id = 1;
SELECT name, email FROM users;
SELECT name FROM users;
SELECT name, email FROM users WHERE id = 1;

-- Вертикальный вывод (только в интерактивном клиенте, вместо ';'):
-- SELECT * FROM users WHERE id = 1\G
