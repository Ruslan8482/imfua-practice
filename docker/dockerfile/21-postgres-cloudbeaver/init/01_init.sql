CREATE TABLE IF NOT EXISTS demo_items (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO demo_items (title) VALUES
  ('Первая запись'),
  ('Вторая запись')
ON CONFLICT DO NOTHING;
