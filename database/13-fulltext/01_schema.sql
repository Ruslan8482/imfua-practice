-- ============================================================
-- Лабораторная 13: FULLTEXT-поиск в MySQL
-- Источник: FULLTEXT.md, раздел 2 «Создание базы fulltext_practice и таблицы articles»
-- ============================================================

CREATE DATABASE fulltext_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE fulltext_practice;

CREATE TABLE articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    author VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
