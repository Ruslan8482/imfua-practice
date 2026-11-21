-- Повторно запускаемый прогон: чистая БД для этой лабораторной.
DROP DATABASE IF EXISTS sql_practice;

-- ============================================================
-- Лабораторная 03 (Begin_MySQL_2.md), шаг 1.
-- Настройка логирования в mysql.general_log, БД sql_practice
-- и VIEW my_actions для фильтрации действий пользователя.
--
-- ВАЖНО: в оригинале для этого задания my.cnf содержит log_output = TABLE.
-- Общий my.cnf этого репозитория использует log_output = FILE, поэтому
-- шаг 1.1 (SET GLOBAL log_output = 'TABLE') обязателен.
-- ============================================================

-- 1.1. Включить общий лог и направить его в таблицу
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE,FILE';

-- Проверка настроек
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'log_output';

-- 1.2. Создать учебную БД
CREATE DATABASE sql_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 1.3. Переключиться на неё
USE sql_practice;

-- 1.4. Убедиться, что база создана
SHOW DATABASES;
SHOW TABLES;

-- 1.5. VIEW для фильтрации лога
-- FROM mysql.general_log указан явно: иначе MySQL искал бы таблицу
-- general_log в текущей базе sql_practice.
CREATE OR REPLACE VIEW my_actions AS
SELECT event_time,
       command_type,
       CONVERT(argument USING utf8mb4) AS argument
FROM mysql.general_log
WHERE user_host LIKE '%root%'
  AND command_type = 'Query'
  AND argument NOT LIKE 'SET %'
  AND argument NOT LIKE 'SHOW %'
  AND argument NOT LIKE 'SELECT @@%'
  AND argument NOT LIKE 'SELECT DATABASE()%'
  AND argument NOT LIKE 'SELECT * FROM my_actions%'
  AND argument NOT LIKE 'TRUNCATE TABLE mysql.general_log%'
  AND argument NOT LIKE 'CREATE OR REPLACE VIEW my_actions%'; -- исключить создание самого VIEW

-- 1.6. Проверить, что VIEW создан
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- 1.7. Использовать VIEW
SELECT * FROM my_actions ORDER BY event_time DESC LIMIT 20;
