-- Повторно запускаемый прогон: чистая БД для этой лабораторной.
DROP DATABASE IF EXISTS my_database;

-- ============================================================
-- Лабораторная 02 (Begin_MySQL_1.md), шаги 1-3.
-- Первый запуск MySQL в Docker, база my_database, таблица users.
-- ============================================================

-- Проверка кодировки сразу после подключения (не обязательно)
SHOW VARIABLES LIKE 'character_set%';

-- 1. Просмотр существующих баз данных
SHOW DATABASES;

-- Команда `help` из инструкции — это команда клиента mysql, а не SQL.
-- В пакетном режиме она не выполняется; в интерактивном введите: help

-- 2. Создание новой базы данных и таблицы
CREATE DATABASE my_database
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE my_database;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3. Выбор базы данных и просмотр таблиц
USE my_database;
SHOW TABLES;
