-- ============================================================
-- Лабораторная 02, шаги 2 и 4: вставка данных в my_database.users.
-- ============================================================

USE my_database;

-- Первоначальное заполнение (шаг 2)
INSERT INTO users (name, email) VALUES
  ('Иван Иванов', 'ivan@example.com'),
  ('Пётр Петров', 'petr@example.com'),
  ('Мария Сидорова', 'maria@example.com');

SELECT * FROM users;

-- Шаг 4: сначала смотрим текущие данные, затем добавляем новые
SELECT * FROM users;

INSERT INTO users (name, email) VALUES ('Павел Иванов', 'pavel@example.com');
INSERT INTO users (name, email) VALUES ('Марк Аврелий', 'mark@example.com');

-- Проверка кодировки после вставки (опционально)
SELECT name, HEX(name) FROM users WHERE id = 1;

-- Шаг 5: просмотр данных
SELECT * FROM users;
