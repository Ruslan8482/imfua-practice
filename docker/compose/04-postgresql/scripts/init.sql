-- Демонстрационный скрипт инициализации (выполняется при ПЕРВОМ запуске тома).
-- ВСЕ пароли ниже — ЗАГЛУШКИ. Замените их перед запуском.
CREATE DATABASE app_db;

CREATE USER app_user WITH PASSWORD 'CHANGE_ME_APP_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE app_db TO app_user;

\connect mydatabase

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
    ('Иван Иванов', 'ivan@example.com'),
    ('Мария Петрова', 'maria@example.com')
ON CONFLICT (email) DO NOTHING;
