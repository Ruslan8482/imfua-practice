-- ============================================================
-- Лабораторная 04, шаг 4: основные операции над products1/products2.
-- EXCEPT и INTERSECT требуют MySQL 8.0.31+; для старых версий
-- приведены закомментированные альтернативы.
-- ============================================================

USE shop;

-- 1. Выборка (SELECT): товары из products1 дороже 150
SELECT * FROM products1 WHERE price > 150;

-- 2. Проекция: только названия товаров
SELECT name FROM products1;

-- 3. Объединение: уникальные названия из обеих таблиц
SELECT name FROM products1
UNION
SELECT name FROM products2;
-- Все строки, включая повторы:
-- SELECT name FROM products1 UNION ALL SELECT name FROM products2;

-- 4. Разность: есть в products1, но нет в products2 (MySQL 8.0.31+)
SELECT name, price FROM products1
EXCEPT
SELECT name, price FROM products2;
-- Альтернатива для MySQL < 8.0.31:
-- SELECT DISTINCT p1.name, p1.price FROM products1 p1
-- LEFT JOIN products2 p2
--   ON p1.name = p2.name AND p1.price = p2.price
-- WHERE p2.name IS NULL;
-- или:
-- SELECT name, price FROM products1
-- WHERE (name, price) NOT IN (SELECT name, price FROM products2);

-- 5. Пересечение: одинаковые название и цена (MySQL 8.0.31+)
SELECT name, price FROM products1
INTERSECT
SELECT name, price FROM products2;
-- Альтернатива для MySQL < 8.0.31:
-- SELECT DISTINCT p1.name, p1.price FROM products1 p1
-- JOIN products2 p2 ON p1.name = p2.name AND p1.price = p2.price;

-- 6. Декартово произведение: 4 x 4 = 16 строк
SELECT t1.name AS name1, t1.price AS price1,
       t2.name AS name2, t2.price AS price2
FROM products1 t1
CROSS JOIN products2 t2;

-- 7. Соединение по названию (совпадающие строки)
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1
JOIN products2 t2 ON t1.name = t2.name;

-- Все товары из products1, даже без пары во второй таблице
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1
LEFT JOIN products2 t2 ON t1.name = t2.name;

-- 8. Деление (DIVISION) в инструкции не рассматривается:
-- для него нужна третья таблица связи (например, «поставщик — товар»).
