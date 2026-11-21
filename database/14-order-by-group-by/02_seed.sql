-- ============================================================
-- Лабораторная 14: 500 строк (10 x 10 x 5) из ORDER_BY_GROUP_BY.md, раздел 2
-- ============================================================

USE sort_practice;

INSERT INTO orders (customer_id, status, order_date, amount)
SELECT
    FLOOR(1 + RAND() * 50),
    ELT(FLOOR(1 + RAND() * 4), 'new', 'paid', 'cancelled', 'shipped'),
    DATE_ADD('2026-01-01', INTERVAL FLOOR(RAND() * 365) DAY),
    ROUND(100 + RAND() * 4900, 2)
FROM
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
     UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) a,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
     UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) b,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c;

-- Проверка: должно быть 500 строк
SELECT COUNT(*) FROM orders;
