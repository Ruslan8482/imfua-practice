-- ============================================================
-- Лабораторная 12: эксперименты 1-6 из Index.md (разделы 4-9)
-- Порядок строгий: сначала EXPLAIN «до», потом CREATE INDEX, потом EXPLAIN «после».
-- ============================================================

USE index_practice;

-- ------------------------------------------------------------
-- Эксперимент 1 (раздел 4): какие индексы уже есть
-- Ожидаем: PRIMARY(id) и customer_id (создан автоматически из FOREIGN KEY).
-- Индекса по amount нет.
-- ------------------------------------------------------------
SHOW INDEX FROM orders;

-- ------------------------------------------------------------
-- Эксперимент 2 (раздел 5): EXPLAIN до индекса
-- Ожидаемый план: type = ALL, key = NULL, rows = 6, Extra = Using where.
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM orders WHERE amount > 1000;

-- ------------------------------------------------------------
-- Эксперимент 3 (раздел 6): CREATE INDEX и EXPLAIN после
-- ------------------------------------------------------------
CREATE INDEX idx_amount ON orders(amount);
SHOW INDEX FROM orders;

EXPLAIN SELECT * FROM orders WHERE amount > 1000;
-- Ожидаемый план: type = range, possible_keys/key = idx_amount, rows = 4.

-- ------------------------------------------------------------
-- Эксперимент 4 (раздел 7): функция в WHERE ломает индекс
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM orders WHERE YEAR(order_date) = 2026;
-- Ожидаемый план: type = ALL, key = NULL (YEAR() applied to every row).

CREATE INDEX idx_order_date ON orders(order_date);
SHOW INDEX FROM orders;

-- Переписанный запрос: функция убрана, условие стало диапазоном
EXPLAIN SELECT * FROM orders
WHERE order_date >= '2026-01-01' AND order_date < '2027-01-01';
-- Ожидаемый план: type = range, key = idx_order_date.

-- ------------------------------------------------------------
-- Эксперимент 5 (раздел 8): составной индекс (левый префикс)
-- (status, amount) работает для status и (status, amount),
-- но не для amount без status.
-- ------------------------------------------------------------
CREATE INDEX idx_status_amount ON orders(status, amount);
SHOW INDEX FROM orders;

-- Использует индекс (status — первый столбец):
EXPLAIN SELECT * FROM orders WHERE status = 'paid';

-- Использует индекс (status + amount):
EXPLAIN SELECT * FROM orders WHERE status = 'paid' AND amount > 1000;

-- Составной индекс НЕ подходит (amount не первый), но может быть использован idx_amount:
EXPLAIN SELECT * FROM orders WHERE amount > 1000;

-- Чтобы увидеть поведение именно составного индекса, временно удаляем idx_amount:
DROP INDEX idx_amount ON orders;
EXPLAIN SELECT * FROM orders WHERE amount > 1000;
-- Ожидаемый план: type = ALL или index, key = NULL/другой индекс;
-- idx_status_amount для этого запроса не подходит.

-- Возвращаем idx_amount (как рекомендует инструкция):
CREATE INDEX idx_amount ON orders(amount);

-- ------------------------------------------------------------
-- Эксперимент 6 (раздел 9): покрывающий индекс, Index-Only Scan
-- ------------------------------------------------------------
CREATE INDEX idx_customer_amount ON orders(customer_id, amount);

EXPLAIN SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id;
-- Ожидаемый план: type = index, key = idx_customer_amount, Extra = Using index.

-- MySQL 8.0.18+: реальное время выполнения шагов плана
EXPLAIN ANALYZE SELECT * FROM orders WHERE amount > 1000;

-- ------------------------------------------------------------
-- Итог (шпаргалка раздела 10):
--   ALL       — полный перебор (плохо)
--   index     — полный просмотр индекса
--   range/ref/eq_ref/const — хорошие типы доступа
--   Using index     — покрывающий индекс, таблица не читается
--   Using where     — фильтрация после чтения
--   Using filesort / Using temporary — требуют оптимизации
--
-- Для «чистого» дампа без экспериментальных индексов (необязательно):
-- DROP INDEX idx_amount ON orders;
-- DROP INDEX idx_order_date ON orders;
-- DROP INDEX idx_status_amount ON orders;
-- DROP INDEX idx_customer_amount ON orders;
-- ------------------------------------------------------------
