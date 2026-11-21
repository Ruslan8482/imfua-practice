-- ============================================================
-- Лабораторная 03, шаг 12.1: просмотр лога через VIEW.
-- Экспорт лога и дамп выполняются командами хоста (см. commands.sh).
-- ============================================================

USE sql_practice;

-- Все действия пользователя из mysql.general_log через VIEW
SELECT * FROM my_actions ORDER BY event_time DESC;

-- Более тонкая фильтрация
SELECT * FROM my_actions
WHERE argument LIKE '%customers%'
ORDER BY event_time DESC
LIMIT 10;

-- Инструкция допускает log_output = 'TABLE,FILE' (и TABLE, и FILE).
-- Включаем FILE дополнительно, чтобы scripts/export-log.sh мог скопировать
-- /var/lib/mysql/general.log из контейнера (общий my.cnf настроен на FILE).
SET GLOBAL log_output = 'TABLE,FILE';

SHOW VARIABLES LIKE 'log_output';
