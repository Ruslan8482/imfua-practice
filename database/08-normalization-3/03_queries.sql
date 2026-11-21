-- Лабораторная № 3 по нормализации: перенос данных, проверки, аномалии.
-- Выполнять после 01_schema.sql и 02_seed.sql.

USE hr_sales_norm;

-- ===========================================================================
-- 1. Перенос данных в 3NF (INSERT ... SELECT)
-- ===========================================================================

-- Уникальные отделы
INSERT INTO departments (department_id, department_name)
SELECT DISTINCT department_id, department_name
FROM employee_sales_unnormalized;

-- Уникальные сотрудники с ссылкой на отдел
INSERT INTO employees (employee_id, employee_name, department_id)
SELECT DISTINCT employee_id, employee_name, department_id
FROM employee_sales_unnormalized;

-- Уникальные месяцы ( month_id = подпись месяца )
INSERT INTO reporting_months (month_id, month_label)
SELECT DISTINCT sale_month, sale_month
FROM employee_sales_unnormalized;

-- Продажи: ссылка на месяц через справочник
INSERT INTO employee_sales (employee_id, month_id, sales_amount)
SELECT s.employee_id, m.month_id, s.sales_amount
FROM employee_sales_unnormalized s
JOIN reporting_months m ON m.month_label = s.sale_month;

SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM reporting_months;
SELECT * FROM employee_sales;

-- ===========================================================================
-- 2. Проверка корректности переноса
-- ===========================================================================

-- 2.1. Общая сумма продаж: ожидается 715000.00 в обоих запросах
SELECT SUM(sales_amount) AS total_old
FROM employee_sales_unnormalized;

SELECT SUM(es.sales_amount) AS total_new
FROM employee_sales es;

-- 2.2. Количества (3/3, 4/4, 2/2, 7/7)
SELECT COUNT(*) AS old_departments FROM
    (SELECT DISTINCT department_id FROM employee_sales_unnormalized) AS t;
SELECT COUNT(*) AS new_departments FROM departments;

SELECT COUNT(*) AS old_employees FROM
    (SELECT DISTINCT employee_id FROM employee_sales_unnormalized) AS t;
SELECT COUNT(*) AS new_employees FROM employees;

SELECT COUNT(*) AS old_months FROM
    (SELECT DISTINCT sale_month FROM employee_sales_unnormalized) AS t;
SELECT COUNT(*) AS new_months FROM reporting_months;

SELECT COUNT(*) AS old_sales FROM employee_sales_unnormalized;
SELECT COUNT(*) AS new_sales FROM employee_sales;

-- 2.3. Продажи сотрудника с кодом 1: ожидается 270000.00
SELECT e.employee_id, e.employee_name, SUM(es.sales_amount) AS total
FROM employees e
JOIN employee_sales es ON e.employee_id = es.employee_id
WHERE e.employee_id = 1
GROUP BY e.employee_id, e.employee_name;

-- 2.4. Продажи по отделам (отдел 10 — 340000.00)
SELECT d.department_id, d.department_name, SUM(es.sales_amount) AS total
FROM departments d
JOIN employees e       ON d.department_id = e.department_id
JOIN employee_sales es ON e.employee_id = es.employee_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;

-- ===========================================================================
-- 3. Аномалии и их исчезновение. Изменения отменяются ROLLBACK.
-- ===========================================================================
START TRANSACTION;

-- 3.1. Аномалия обновления: переименовали отдел 10 только в одной строке.
UPDATE employee_sales_unnormalized
SET department_name = 'Отдел продаж'
WHERE employee_id = 1 AND sale_month = '2026-01';

SELECT DISTINCT department_id, department_name
FROM employee_sales_unnormalized
WHERE department_id = 10; -- два названия у одного отдела

-- В 3NF название меняется в одной строке departments.
UPDATE departments SET department_name = 'Отдел продаж' WHERE department_id = 10;
SELECT * FROM departments WHERE department_id = 10;

-- 3.2. Аномалия удаления: удаляем все продажи сотрудника 4.
DELETE FROM employee_sales_unnormalized WHERE employee_id = 4;
SELECT * FROM employee_sales_unnormalized WHERE employee_id = 4; -- сотрудник исчез
SELECT * FROM employees WHERE employee_id = 4;                   -- а здесь остался
SELECT * FROM departments WHERE department_id = 10;              -- отдел тоже остался

-- В 3NF удаляем только факты продаж.
DELETE FROM employee_sales WHERE employee_id = 4;
SELECT * FROM employees WHERE employee_id = 4;

-- 3.3. Аномалия вставки: отдел без сотрудников и продаж в «плохой» таблице.
INSERT INTO employee_sales_unnormalized (department_id, department_name)
VALUES (99, 'Отдел качества');
SELECT * FROM employee_sales_unnormalized WHERE department_id = 99; -- NULL в остальных полях

-- В 3NF отдел добавляется отдельно.
INSERT INTO departments (department_id, department_name)
VALUES (99, 'Отдел качества');
SELECT * FROM departments WHERE department_id = 99;

ROLLBACK; -- вернули демонстрационные изменения

-- ===========================================================================
-- 4. Удаление старой таблицы после проверок
-- ===========================================================================
DROP TABLE employee_sales_unnormalized;

SHOW TABLES;
