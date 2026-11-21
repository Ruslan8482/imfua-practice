-- ============================================================
-- Лабораторная 15: эксперименты 1-6 из Index_JOIN.md (разделы 4-9)
-- Порядок: JOIN без индекса -> индекс -> FK -> порядок соединения ->
--          составной индекс -> INNER vs LEFT.
-- Демонстрация автоматического индекса для FK — в 04_fk_demo.sql.
-- ============================================================

USE join_practice;

-- ------------------------------------------------------------
-- Эксперимент 1 (раздел 4): JOIN без индекса на столбце соединения
-- Запрос: все заказы пользователей с vip_level = 3.
-- Ожидаемый фрагмент плана:
--   u  ALL     NULL       50  Using where
--   o  ALL     NULL      500  Using where; Using join buffer
-- ------------------------------------------------------------
EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;

-- ------------------------------------------------------------
-- Эксперимент 2 (раздел 5): индекс на столбце соединения
-- ------------------------------------------------------------
CREATE INDEX idx_user_id ON orders(user_id);
SHOW INDEX FROM orders;

EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;
-- Ожидаемый фрагмент: o  ref  idx_user_id  ~10  Using where

-- Проверка результата запроса (для отчёта):
SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3
ORDER BY o.id
LIMIT 20;

-- ------------------------------------------------------------
-- Раздел 6: внешний ключ и автоматический индекс
-- Если бы сразу было объявлено:
-- ALTER TABLE orders
--   ADD CONSTRAINT fk_orders_user
--   FOREIGN KEY (user_id) REFERENCES users(id);
-- InnoDB создал бы индекс на user_id автоматически. Полная демонстрация —
-- в 04_fk_demo.sql (таблица orders_fk с FK).

-- ------------------------------------------------------------
-- Раздел 7: порядок соединения (первая строка EXPLAIN — driving table)
-- ------------------------------------------------------------
EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;

-- Принудительный порядок (только для сравнения; без крайней нужды не применять):
EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
STRAIGHT_JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;

-- ------------------------------------------------------------
-- Раздел 8: составной индекс для JOIN + WHERE
-- ------------------------------------------------------------
CREATE INDEX idx_user_status ON orders(user_id, status);
SHOW INDEX FROM orders;

SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3 AND o.status = 'paid'
ORDER BY o.id
LIMIT 20;

EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3 AND o.status = 'paid';

-- ------------------------------------------------------------
-- Раздел 9: INNER JOIN vs LEFT JOIN
-- LEFT JOIN: левая таблица фиксирована как driving, индекс справа критичен.
-- Фильтр по правой таблице в WHERE превращает LEFT JOIN в INNER JOIN.
-- ------------------------------------------------------------
EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;

EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;

-- LEFT JOIN без фильтра по правой таблице:
EXPLAIN SELECT o.id, o.amount, u.name
FROM orders o
LEFT JOIN users u ON o.user_id = u.id;

-- MySQL 8.0.18+: Hash Join виден через EXPLAIN FORMAT=TREE
EXPLAIN FORMAT=TREE
SELECT o.id, o.amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.vip_level = 3;

-- ------------------------------------------------------------
-- Итог (раздел 10):
--   eq_ref — поиск по PK/UNIQUE (лучший), ref — по обычному индексу,
--   ALL    — полный перебор (плохо), index — просмотр индекса.
-- Для «чистого» дампа можно удалить индексы (необязательно):
-- DROP INDEX idx_user_id ON orders;
-- DROP INDEX idx_user_status ON orders;
-- ------------------------------------------------------------
