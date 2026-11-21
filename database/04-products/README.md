### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Products.md)

# Лабораторная 04 — основные операции на примере `products 1` и `products 2`

> **Оригинал:** [Products.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Products.md)
>
> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

На практике выполнить реляционные операции над таблицами `products1` и `products2`
базы `shop`: выборку, проекцию, `UNION`, разность (`EXCEPT`), пересечение
(`INTERSECT`), декартово произведение (`CROSS JOIN`) и соединения (`JOIN`,
`LEFT JOIN`); сделать дамп, удалить и восстановить БД.

## 🧰 Используемый образ и контейнер

- Образ из инструкции: `mysql:latest` (нужен MySQL **8.0.31+** для `EXCEPT`/`INTERSECT`;
  для старых версий в SQL-файле есть альтернативы). Контейнер здесь —
  `imfua-04-products`, в инструкции — `products-mysql`.
- Пароль `root` — `123`.
- `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf), UTF-8 без BOM, LF;
  помимо кодировки включает `general_log`, поэтому лог действий выгружается и для
  этой лабораторной.

## 📋 Ход выполнения

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

## 📊 Результаты

Все шесть SQL-файлов выполнены с кодом возврата 0, ошибок в выводе нет
(см. [RESULT.txt](artifacts/RESULT.txt)).

**Исходные таблицы (факт):**

```text
name	price
Дыни	800
Клубника	150
Яблоки	120
Лимоны	200
name	price
Дыни	800
Клубника	150
Каштаны	200
Хурма	350
```

**Операции (факт из `03_queries.sql`):**

- `WHERE price > 150` → `Дыни 800`, `Лимоны 200`.
- Проекция `SELECT name FROM products1` → 4 названия.
- `UNION` → 6 строк: Дыни, Клубника, Яблоки, Лимоны, Каштаны, Хурма.
- `EXCEPT` → `Яблоки 120`, `Лимоны 200`.
- `INTERSECT` → `Дыни 800`, `Клубника 150`.
- `CROSS JOIN` → 16 строк; `JOIN` → 2 строки; `LEFT JOIN` → 4 строки
  (для Яблоки/Лимоны `price2 = NULL`).

```text
name1	price1	name2	price2
Дыни	800	Дыни	800
Клубника	150	Дыни	800
Яблоки	120	Дыни	800
Лимоны	200	Дыни	800
Дыни	800	Клубника	150
Клубника	150	Клубника	150
Яблоки	120	Клубника	150
Лимоны	200	Клубника	150
Дыни	800	Каштаны	200
Клубника	150	Каштаны	200
Яблоки	120	Каштаны	200
Лимоны	200	Каштаны	200
Дыни	800	Хурма	350
Клубника	150	Хурма	350
Яблоки	120	Хурма	350
Лимоны	200	Хурма	350
name	price1	price2
Дыни	800	800
Клубника	150	150
name	price1	price2
Дыни	800	800
Клубника	150	150
Яблоки	120	NULL
Лимоны	200	NULL
```

**Удаление и восстановление (факт):** `04_drop.sql` — `shop` был в `SHOW DATABASES`,
`tables products1/products2`, после `DROP DATABASE shop` базы в списке нет;
`04_restore.sql` и `04_verify.sql` — `shop` снова в списке, таблицы `products1`
и `products2` на месте, по 4 строки в каждой. Кириллица в выводе корректная:
клиент запускается с `--default-character-set=utf8mb4`, полный вывод — в
[execution-output.txt](artifacts/execution-output.txt).

Скриншоты в `evidence/` не создавались (нет GUI).

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — сырой `general.log` MariaDB (9102 байт).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованный лог действий (165 строк).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — полный вывод шести SQL-скриптов (3050 байт).
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — сводка прогона: коды возврата 0, 0 ошибок.
- [artifacts/shop-dump.sql](artifacts/shop-dump.sql) — дамп БД `shop` (2674 байт).
- [artifacts/shop-pre-drop-dump.sql](artifacts/shop-pre-drop-dump.sql) — дамп перед удалением БД (2450 байт).

## ✅ Чек-лист сдачи

- [ ] Контейнер поднят с `mysql:latest` (MySQL 8.0.31+), кодировка utf8mb4.
- [ ] БД `shop`, таблицы `products1` и `products2` созданы и заполнены.
- [ ] Все 7 операций шага 4 выполнены, результаты совпадают с ожидаемыми.
- [ ] `EXCEPT`/`INTERSECT` работают (либо применены альтернативы для старой версии).
- [ ] Дамп создан до удаления БД, БД удалена и восстановлена из дампа.
- [ ] Лог выгружен и отфильтрован, дамп не пуст.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
