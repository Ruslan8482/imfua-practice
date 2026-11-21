-- Повторно запускаемый прогон: чистая БД для этой лабораторной.
DROP DATABASE IF EXISTS hr_sales_norm;

-- Лабораторная № 3 по нормализации: схема.
-- Источник: https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_3.md
-- В оригинале есть только заголовки таблицы и названия отделов; строки — демонстрационные (см. README.md).

CREATE DATABASE IF NOT EXISTS hr_sales_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE hr_sales_norm;

DROP TABLE IF EXISTS employee_sales;
DROP TABLE IF EXISTS reporting_months;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS employee_sales_unnormalized;

-- ---------------------------------------------------------------------------
-- Исходная «плохая» таблица: код и имя сотрудника, месяц, продажи,
-- код и название отдела повторяются в каждой строке.
-- ---------------------------------------------------------------------------
CREATE TABLE employee_sales_unnormalized (
    employee_id     INT,
    employee_name   VARCHAR(100),
    sale_month      VARCHAR(7),
    sales_amount    DECIMAL(12,2),
    department_id   INT,
    department_name VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Четыре таблицы в 3NF. Создаются пустыми: данные переносятся в 03_queries.sql.
-- ---------------------------------------------------------------------------

-- 1. Отделы
CREATE TABLE departments (
    department_id   INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Сотрудники (один отдел на сотрудника)
CREATE TABLE employees (
    employee_id   INT NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (employee_id),
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Месяцы отчётности
CREATE TABLE reporting_months (
    month_id    VARCHAR(7) NOT NULL,
    month_label VARCHAR(7) NOT NULL,
    PRIMARY KEY (month_id),
    CONSTRAINT uq_reporting_months_label UNIQUE (month_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Факты продаж
CREATE TABLE employee_sales (
    employee_id  INT NOT NULL,
    month_id     VARCHAR(7) NOT NULL,
    sales_amount DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (employee_id, month_id),
    CONSTRAINT fk_sales_employee FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id),
    CONSTRAINT fk_sales_month FOREIGN KEY (month_id)
        REFERENCES reporting_months (month_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
