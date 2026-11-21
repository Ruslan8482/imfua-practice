-- ============================================================
-- Лабораторная 15, раздел 6: FOREIGN KEY автоматически создаёт индекс
-- Дополнительная демонстрация (в инструкции показан гипотетический
-- ALTER TABLE orders ADD CONSTRAINT fk_orders_user ...).
-- Здесь создаём отдельную таблицу orders_fk, чтобы не испортить
-- результаты экспериментов 1-2, где индекса на user_id быть не должен.
-- ============================================================

USE join_practice;

CREATE TABLE orders_fk (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'new',
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Индекс на user_id создаётся InnoDB автоматически вместе с FK
SHOW INDEX FROM orders_fk;

-- Заполняем демонстрационную таблицу данными из orders
INSERT INTO orders_fk (user_id, order_date, amount, status)
SELECT user_id, order_date, amount, status FROM orders;

SELECT COUNT(*) FROM orders_fk;   -- 500

-- Сравнение: план JOIN на таблице с автоматическим индексом FK
EXPLAIN SELECT f.id, f.amount, u.name
FROM orders_fk f
JOIN users u ON f.user_id = u.id
WHERE u.vip_level = 3;
-- Ожидается: type = ref, key = user_id (имя авто-индекса совпадает со столбцом).
