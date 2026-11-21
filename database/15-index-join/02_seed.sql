-- ============================================================
-- Лабораторная 15: 50 пользователей и 500 заказов (Index_JOIN.md, раздел 2)
-- ============================================================

USE join_practice;

INSERT INTO users (name, email, vip_level)
SELECT
    CONCAT('User', n),
    CONCAT('user', n, '@example.com'),
    FLOOR(RAND() * 4)
FROM (
    SELECT a.n + b.n * 10 + 1 AS n
    FROM (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) b
) numbers;

INSERT INTO orders (user_id, order_date, amount, status)
SELECT
    FLOOR(1 + RAND() * 50),
    DATE_ADD('2026-01-01', INTERVAL FLOOR(RAND() * 365) DAY),
    ROUND(100 + RAND() * 4900, 2),
    ELT(FLOOR(1 + RAND() * 3), 'new', 'paid', 'cancelled')
FROM
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
     UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) a,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
     UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) b,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c;

-- Проверка: 50 пользователей, 500 заказов
SELECT COUNT(*) FROM users;   -- 50
SELECT COUNT(*) FROM orders;  -- 500
