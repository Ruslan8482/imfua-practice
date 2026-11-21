-- ============================================================
-- Лабораторная 14: эксперименты 1-7 из ORDER_BY_GROUP_BY.md (разделы 4-10)
-- Порядок: EXPLAIN «до» -> CREATE INDEX -> EXPLAIN «после».
-- ============================================================

USE sort_practice;

-- ------------------------------------------------------------
-- Эксперимент 1 (раздел 4): ORDER BY без индекса
-- Ожидаемый план: type = ALL, key = NULL, rows = 500,
--                 Extra = Using filesort
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM orders ORDER BY amount DESC;

-- ------------------------------------------------------------
-- Эксперимент 2 (раздел 5): индекс, соответствующий ORDER BY
-- ------------------------------------------------------------
CREATE INDEX idx_amount ON orders(amount);

EXPLAIN SELECT * FROM orders ORDER BY amount DESC;
-- Ожидаемый план: type = index, key = idx_amount,
-- Extra без Using filesort (NULL или Using index).

-- ------------------------------------------------------------
-- Эксперимент 3 (раздел 6): направление сортировки
-- ------------------------------------------------------------

-- 6.1. ASC: MySQL может прочитать idx_amount в обратном порядке (backward scan)
EXPLAIN SELECT * FROM orders ORDER BY amount ASC;

-- 6.2. Составной индекс для сортировки по двум столбцам
CREATE INDEX idx_status_amount ON orders(status, amount);

-- Однородная сортировка: индекс используется, filesort исчезает
EXPLAIN SELECT * FROM orders ORDER BY status ASC, amount ASC;

-- Разнонаправленная сортировка: (status ASC, amount ASC) не подходит
EXPLAIN SELECT * FROM orders ORDER BY status ASC, amount DESC;
-- Ожидаемый план: Extra = Using filesort

-- MySQL 8.0+: нисходящий индекс снимает filesort для смешанного направления
CREATE INDEX idx_status_amount_desc ON orders(status ASC, amount DESC);

EXPLAIN SELECT * FROM orders ORDER BY status ASC, amount DESC;
-- Ожидаемый план: key = idx_status_amount_desc, Extra без Using filesort

-- ------------------------------------------------------------
-- Эксперимент 4 (раздел 7): GROUP BY без индекса
-- Ожидаемый план: type = ALL, key = NULL, rows = 500,
--                 Extra = Using temporary; Using filesort
-- ------------------------------------------------------------
EXPLAIN SELECT status, COUNT(*) FROM orders GROUP BY status;

-- ------------------------------------------------------------
-- Эксперимент 5 (раздел 8): индекс по GROUP BY, Loose Index Scan
-- ------------------------------------------------------------
CREATE INDEX idx_status ON orders(status);

EXPLAIN SELECT status, COUNT(*) FROM orders GROUP BY status;
-- Ожидаемый план: type = index, key = idx_status, rows = 4 (или меньше),
-- Extra без Using temporary / Using filesort

-- ------------------------------------------------------------
-- Эксперимент 6 (раздел 9): Tight Index Scan (SUM вместо MIN/MAX)
-- ------------------------------------------------------------
EXPLAIN SELECT status, SUM(amount) FROM orders GROUP BY status;
-- Extra может быть Using index или пустым, но без Using temporary

-- ------------------------------------------------------------
-- Эксперимент 7 (раздел 10): покрывающий индекс для GROUP BY
-- ------------------------------------------------------------
CREATE INDEX idx_status_amount_cover ON orders(status, amount);

EXPLAIN SELECT status, SUM(amount) FROM orders GROUP BY status;
-- Ожидаемый план: Extra = Using index; временная таблица не создаётся

-- ------------------------------------------------------------
-- Итоговая шпаргалка (раздел 11):
--   ORDER BY col            -> INDEX(col)             -> без Using filesort
--   ORDER BY col1, col2     -> INDEX(col1, col2)      -> без Using filesort
--   WHERE col=const ORDER BY col2 -> INDEX(col, col2) -> без Using filesort
--   GROUP BY col            -> INDEX(col)             -> без Using temporary
--   GROUP BY col1, col2     -> INDEX(col1, col2)      -> без Using temporary
--   GROUP BY col + агрегат  -> INDEX(col, agg_col)    -> Using index
--
-- Для «чистого» дампа можно удалить экспериментальные индексы (необязательно):
-- DROP INDEX idx_amount ON orders;
-- DROP INDEX idx_status_amount ON orders;
-- DROP INDEX idx_status_amount_desc ON orders;
-- DROP INDEX idx_status ON orders;
-- DROP INDEX idx_status_amount_cover ON orders;
-- ------------------------------------------------------------
