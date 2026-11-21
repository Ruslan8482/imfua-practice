# Лабораторная 04 — основные операции на примере `products 1` и `products 2`

> **Оригинал:** [Products.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Products.md)
>
> **Внимание:** в этой среде нет Docker/MySQL. Реальные логи, дампы и скриншоты
> создаются при запуске на машине с Docker. Плейсхолдеры `<вставьте …>` и ссылки
> `evidence/*.png` в шаблоне заполняются после выполнения.

## Цель

На практике выполнить реляционные операции над таблицами `products1` и `products2`
базы `shop`: выборку, проекцию, `UNION`, разность (`EXCEPT`), пересечение
(`INTERSECT`), декартово произведение (`CROSS JOIN`) и соединения (`JOIN`,
`LEFT JOIN`); сделать дамп, удалить и восстановить БД.

## Используемый образ и контейнер

- Образ из инструкции: `mysql:latest` (нужен MySQL **8.0.31+** для `EXCEPT`/`INTERSECT`;
  для старых версий в SQL-файле есть альтернативы). Контейнер здесь —
  `imfua-04-products`, в инструкции — `products-mysql`.
- Пароль `root` — `123`.
- `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf), UTF-8 без BOM, LF;
  помимо кодировки включает `general_log`, поэтому лог действий выгружается и для
  этой лабораторной.

## Ход выполнения

### Шаг 1. Подготовка и БД

```bash
docker ps -a
docker stop имя_контейнера
docker container prune
docker volume prune -a            # осторожно: удаляет все неиспользуемые тома
rm general.log index_dump_clean.sql index_dump.sql my_actions.log
mkdir products-mysql && cd products-mysql
# my.cnf см. в этом каталоге

docker run --name products-mysql \
  -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
  -d mysql:latest
docker ps
docker exec -it products-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

```sql
CREATE DATABASE shop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE shop;
SHOW DATABASES;
```

### Шаг 2. Таблицы

```sql
CREATE TABLE products1 (
    name  VARCHAR(100) NOT NULL,
    price INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE products2 (
    name  VARCHAR(100) NOT NULL,
    price INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW TABLES;
```

### Шаг 3. Данные

```sql
INSERT INTO products1 (name, price) VALUES
  ('Дыни', 800), ('Клубника', 150), ('Яблоки', 120), ('Лимоны', 200);
INSERT INTO products2 (name, price) VALUES
  ('Дыни', 800), ('Клубника', 150), ('Каштаны', 200), ('Хурма', 350);
SELECT * FROM products1;
SELECT * FROM products2;
```

### Шаг 4. Основные операции

```sql
-- 1. Выборка
SELECT * FROM products1 WHERE price > 150;

-- 2. Проекция
SELECT name FROM products1;

-- 3. Объединение
SELECT name FROM products1 UNION SELECT name FROM products2;

-- 4. Разность (MySQL 8.0.31+)
SELECT name, price FROM products1
EXCEPT
SELECT name, price FROM products2;

-- 5. Пересечение (MySQL 8.0.31+)
SELECT name, price FROM products1
INTERSECT
SELECT name, price FROM products2;

-- 6. Декартово произведение: 16 строк
SELECT t1.name AS name1, t1.price AS price1,
       t2.name AS name2, t2.price AS price2
FROM products1 t1 CROSS JOIN products2 t2;

-- 7. Соединения
SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1 JOIN products2 t2 ON t1.name = t2.name;

SELECT t1.name, t1.price AS price1, t2.price AS price2
FROM products1 t1 LEFT JOIN products2 t2 ON t1.name = t2.name;
```

Полные запросы и альтернативы для MySQL < 8.0.31 —
в [03_queries.sql](03_queries.sql). Операция деления в инструкции не рассматривается
(нужна третья таблица связи).

### Шаг 5. Дамп

```bash
\q
docker exec -e MYSQL_PWD=123 products-mysql mysqldump -uroot shop > dump.sql
cat dump.sql
cd database
bash ../scripts/dump-db.sh 04-products shop
bash ../scripts/export-log.sh 04-products
```

### Шаг 6. Уборка

```sql
SHOW DATABASES;
USE shop;
SHOW TABLES;
DROP DATABASE shop;
SHOW DATABASES;
\q
```

### Шаг 7. Восстановление

```bash
docker exec -it products-mysql mysql --default-character-set=utf8mb4 -uroot -p
SHOW DATABASES;
CREATE DATABASE shop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
\q
# импорт выполняется на хосте, не внутри mysql:
docker exec -i products-mysql mysql -uroot -p123 --force shop < dump.sql
docker exec -it products-mysql mysql --default-character-set=utf8mb4 -uroot -p
SHOW DATABASES;
USE shop;
SHOW TABLES;
SELECT * FROM products1;
SELECT * FROM products2;
```

Полная последовательность — в [commands.sh](commands.sh).

## Результаты

**Ожидаемые результаты запросов:**

- `WHERE price > 150` → `Дыни 800`, `Лимоны 200`.
- `UNION` → 6 уникальных названий: Дыни, Клубника, Яблоки, Лимоны, Каштаны, Хурма.
- `EXCEPT` → `Яблоки 120`, `Лимоны 200`.
- `INTERSECT` → `Дыни 800`, `Клубника 150`.
- `CROSS JOIN` → 16 строк; `JOIN` → 2 строки; `LEFT JOIN` → 4 строки
  (для Яблоки/Лимоны `price2 = NULL`).

**Фактический вывод (заполнить):**

```text
<вставьте вывод SELECT * FROM products1/products2>
<вставьте вывод UNION / EXCEPT / INTERSECT / CROSS JOIN / JOIN / LEFT JOIN>
<вставьте вывод SHOW TABLES и SELECT после восстановления БД>
```

![Таблицы products1 и products2](evidence/01-products-tables.png)
![Разность и пересечение](evidence/02-except-intersect.png)
![JOIN и CROSS JOIN](evidence/03-joins.png)
![Восстановленная БД shop](evidence/04-restore.png)

## Лог и дамп

- `artifacts/general.log` — сырой лог MySQL (в инструкции — `general.log`).
- `artifacts/my_actions.log` — отфильтрованный лог действий.
- `artifacts/shop-dump.sql` — дамп БД `shop` (в инструкции — `dump.sql`).

![Лог действий](evidence/05-log.png)
![Дамп shop](evidence/06-dump.png)

## Чек-лист сдачи

- [ ] Контейнер поднят с `mysql:latest` (MySQL 8.0.31+), кодировка utf8mb4.
- [ ] БД `shop`, таблицы `products1` и `products2` созданы и заполнены.
- [ ] Все 7 операций шага 4 выполнены, результаты совпадают с ожидаемыми.
- [ ] `EXCEPT`/`INTERSECT` работают (либо применены альтернативы для старой версии).
- [ ] Дамп создан до удаления БД, БД удалена и восстановлена из дампа.
- [ ] Лог выгружен и отфильтрован, дамп не пуст.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.
