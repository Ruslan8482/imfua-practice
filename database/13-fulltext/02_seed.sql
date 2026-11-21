-- ============================================================
-- Лабораторная 13: данные из FULLTEXT.md, раздел 2 (5 статей)
-- ============================================================

USE fulltext_practice;

INSERT INTO articles (title, body, author) VALUES
  ('MySQL FULLTEXT search', 'MySQL provides full-text search capabilities. You can search for words in text columns using MATCH AGAINST syntax. FULLTEXT indexes are fast.', 'Иван'),
  ('MySQL replication', 'MySQL replication allows you to replicate data from one server to another. It is useful for backup and scaling. FULLTEXT search works well with replication.', 'Мария'),
  ('Optimizing MySQL queries', 'Query optimization is important for performance. Use indexes, EXPLAIN, and FULLTEXT search to speed up slow queries.', 'Пётр'),
  ('InnoDB full-text search', 'InnoDB supports FULLTEXT indexes since MySQL 5.6. InnoDB full-text search is crash-safe and does not have the 50% threshold that MyISAM has.', 'Ольга'),
  ('Boolean mode in MySQL', 'Boolean mode allows you to use operators like + (required), - (excluded), * (wildcard), and "..." (phrase) in FULLTEXT searches.', 'Алексей');

-- Проверка
SELECT * FROM articles;
