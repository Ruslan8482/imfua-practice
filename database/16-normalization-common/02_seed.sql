-- ============================================================
-- Лабораторная 16: данные из Normalization.md, раздел 2.3
-- ============================================================

USE shop_norm;

INSERT INTO orders_bad (customer_name, customer_city, product_name, product_price, quantity, order_date) VALUES
  ('Иван',  'Москва',          'Яблоки',   120, 2, '2026-10-01'),
  ('Иван',  'Москва',          'Лимоны',   200, 1, '2026-10-01'),
  ('Мария', 'Казань',          'Яблоки',   120, 3, '2026-10-02'),
  ('Мария', 'Казань',          'Хурма',    350, 1, '2026-10-03'),
  ('Пётр',  'Санкт-Петербург', 'Каштаны',  200, 2, '2026-10-04');

SHOW TABLES;
SELECT * FROM orders_bad;

-- Сколько потратил Иван? (до изменений: 120*2 + 200*1 = 440)
SELECT SUM(product_price * quantity) AS total
FROM orders_bad
WHERE customer_name = 'Иван';

-- План запроса «до нормализации» — для таблицы отчёта
EXPLAIN SELECT SUM(product_price * quantity) AS total
FROM orders_bad
WHERE customer_name = 'Иван';
