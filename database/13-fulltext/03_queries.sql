-- ============================================================
-- Лабораторная 13: FULLTEXT-поиск
-- Источник: FULLTEXT.md, разделы 3-9
-- Порядок: LIKE -> FULLTEXT-индекс -> NATURAL LANGUAGE ->
--          BOOLEAN MODE -> ограничения InnoDB -> LIKE vs FULLTEXT ->
--          WITH QUERY EXPANSION
-- ============================================================

USE fulltext_practice;

-- ------------------------------------------------------------
-- 3. Проблема LIKE: полный перебор (до создания FULLTEXT-индекса)
-- Ожидаемый план: type = ALL, key = NULL, rows = 5, Extra = Using where
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM articles WHERE body LIKE '%replication%';

-- ------------------------------------------------------------
-- 4. Создание FULLTEXT-индекса (перевёрнутый индекс)
-- ------------------------------------------------------------
CREATE FULLTEXT INDEX ft_articles ON articles(title, body);
SHOW INDEX FROM articles;   -- Index_type = FULLTEXT

-- ------------------------------------------------------------
-- 5. Режим естественного языка (NATURAL LANGUAGE MODE)
-- ------------------------------------------------------------

-- 5.1. Простейший поиск (режим по умолчанию):
SELECT id, title,
       MATCH(title, body) AGAINST ('replication') AS score
FROM articles
WHERE MATCH(title, body) AGAINST ('replication')
ORDER BY score DESC;

-- То же с явным указанием режима:
SELECT id, title,
       MATCH(title, body) AGAINST ('replication' IN NATURAL LANGUAGE MODE) AS score
FROM articles
WHERE MATCH(title, body) AGAINST ('replication' IN NATURAL LANGUAGE MODE)
ORDER BY score DESC;

-- 5.2. Несколько слов: в NATURAL LANGUAGE MODE объединяются через OR,
-- порядок слов не важен, регистр обычно игнорируется.
SELECT id, title, MATCH(title, body) AGAINST ('MySQL replication') AS score
FROM articles
WHERE MATCH(title, body) AGAINST ('MySQL replication')
ORDER BY score DESC;

-- ------------------------------------------------------------
-- 6. Булев режим (BOOLEAN MODE): точный контроль
-- Операторы: + обязательно, - исключить, * wildcard,
--            "..." точная фраза, ~ снизить релевантность,
--            > повысить вес, < понизить вес, (...) группировка.
-- В BOOLEAN MODE нет автоматической сортировки по релевантности —
-- при необходимости: ORDER BY MATCH(...) AGAINST(...) DESC.
-- ------------------------------------------------------------

-- 6.1. Базовый синтаксис:
SELECT id, title
FROM articles
WHERE MATCH(title, body) AGAINST ('+MySQL -replication' IN BOOLEAN MODE);

-- 6.3. Есть MySQL, но нет replication:
SELECT id, title FROM articles
WHERE MATCH(title, body) AGAINST ('+MySQL -replication' IN BOOLEAN MODE);

-- Точная фраза "query optimization":
SELECT id, title FROM articles
WHERE MATCH(title, body) AGAINST ('"query optimization"' IN BOOLEAN MODE);

-- Слова, начинающиеся на replicat (wildcard):
SELECT id, title FROM articles
WHERE MATCH(title, body) AGAINST ('replicat*' IN BOOLEAN MODE);

-- MySQL-индексы, но не MyISAM (группировка):
SELECT id, title FROM articles
WHERE MATCH(title, body) AGAINST ('+MySQL +(index* partition*) -MyISAM' IN BOOLEAN MODE);

-- Пример с сортировкой по релевантности и операторами ~ / > / <:
SELECT id, title,
       MATCH(title, body) AGAINST ('+MySQL ~performance >FULLTEXT' IN BOOLEAN MODE) AS score
FROM articles
WHERE MATCH(title, body) AGAINST ('+MySQL ~performance >FULLTEXT' IN BOOLEAN MODE)
ORDER BY score DESC;

-- ------------------------------------------------------------
-- 7. Ограничения InnoDB: стоп-слова и длина слова
-- ------------------------------------------------------------
SHOW VARIABLES LIKE 'innodb_ft_min_token_size';   -- по умолчанию 3
SHOW VARIABLES LIKE 'innodb_ft_enable_stopword';  -- по умолчанию ON
SHOW VARIABLES LIKE 'innodb_ft_max_token_size';   -- по умолчанию 84

-- Если нужно индексировать 2-буквенные слова, добавьте в my.cnf:
--   [mysqld]
--   innodb_ft_min_token_size = 2
-- и ПЕРЕСОЗДАЙТЕ индекс (после изменения параметра):
-- ALTER TABLE articles DROP INDEX ft_articles;
-- ALTER TABLE articles ADD FULLTEXT INDEX ft_articles (title, body);
--
-- Отключение стоп-слов (тоже требует пересоздания индекса):
-- SET GLOBAL innodb_ft_enable_stopword = OFF;

-- ------------------------------------------------------------
-- 8. Сравнение LIKE vs FULLTEXT
-- ------------------------------------------------------------

-- LIKE после создания FULLTEXT: по-прежнему полный перебор
EXPLAIN SELECT * FROM articles WHERE body LIKE '%replication%';

-- FULLTEXT: type = fulltext, key = ft_articles
EXPLAIN SELECT * FROM articles WHERE MATCH(title, body) AGAINST ('replication');

-- ------------------------------------------------------------
-- 9. WITH QUERY EXPANSION: поиск выполняется дважды —
-- сначала по исходному слову, затем по словам найденных документов.
-- ------------------------------------------------------------
SELECT id, title
FROM articles
WHERE MATCH(title, body) AGAINST ('replication' WITH QUERY EXPANSION);

-- С релевантностью и сортировкой (расширение может добавить «шум»):
SELECT id, title,
       MATCH(title, body) AGAINST ('replication' WITH QUERY EXPANSION) AS score
FROM articles
WHERE MATCH(title, body) AGAINST ('replication' WITH QUERY EXPANSION)
ORDER BY score DESC;

-- 10. Лог и 11. Дамп: см. commands.sh
--     general.log -> artifacts/my_actions.log,
--     mysqldump   -> artifacts/fulltext_practice-dump.sql (индекс ft_articles внутри).
