### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_2.md)

# Лабораторная № 2 по нормализации: `sales_unnormalized` → 3NF

- **Оригинал:** [Normalization_2.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_2.md)
- **Каталог:** `database/07-normalization-2`
- **Контейнер:** `imfua-07-normalization-2`
- **База данных:** `sales_norm`
- **Порядок файлов:** `01_schema.sql` → `02_seed.sql` → `03_queries.sql`; запуск — `commands.sh`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 1. Цель

1. Создать базу `sales_norm` и «плохую» таблицу `sales_unnormalized` с исходными строками.
2. Продемонстрировать аномалии обновления, удаления и вставки.
3. Привести таблицу к 3NF: `clients`, `products`, `sales`, `sale_items`.
4. Перенести данные через `INSERT ... SELECT`, сверить суммы и количества.
5. Показать, что аномалии в нормализованной схеме исчезли.
6. Сделать дампы до/после нормализации и выгрузить отфильтрованный лог действий.

## 2. Исходная ненормализованная таблица

`CREATE TABLE sales_unnormalized`, 10 строк строго из инструкции (`02_seed.sql`):

| sale_id | sale_date | client_id | client_name | client_city | product_id | product_name | unit_price | quantity |
|---------|-----------|-----------|-------------|-------------|------------|--------------|------------|----------|
| 5001 | 2026-11-01 | 101 | Иванов Иван | Москва | 201 | Монитор | 15000.00 | 2 |
| 5001 | 2026-11-01 | 101 | Иванов Иван | Москва | 202 | Клавиатура | 2000.00 | 1 |
| 5002 | 2026-11-02 | 102 | Петрова Мария | Санкт-Петербург | 203 | Мышь | 1000.00 | 3 |
| 5002 | 2026-11-02 | 102 | Петрова Мария | Санкт-Петербург | 204 | Наушники | 3500.00 | 1 |
| 5003 | 2026-11-03 | 101 | Иванов Иван | Москва | 205 | Колонки | 2500.00 | 2 |
| 5004 | 2026-11-04 | 103 | Сидоров Алексей | Казань | 202 | Клавиатура | 2000.00 | 5 |
| 5004 | 2026-11-04 | 103 | Сидоров Алексей | Казань | 203 | Мышь | 1000.00 | 2 |
| 5005 | 2026-11-05 | 102 | Петрова Мария | Санкт-Петербург | 201 | Монитор | 15000.00 | 1 |
| 5006 | 2026-11-06 | 103 | Сидоров Алексей | Казань | 204 | Наушники | 3500.00 | 2 |
| 5006 | 2026-11-06 | 103 | Сидоров Алексей | Казань | 205 | Колонки | 2500.00 | 1 |

### Нарушения

1. **Повторяющиеся группы.** Для продажи 5001 данные клиента и дата повторяются в каждой строке товара.
2. **2NF.** Ключ — `(sale_id, product_id)`; `sale_date`, `client_id`, `client_name`, `client_city` зависят только от `sale_id`, а `product_name`, `unit_price` — только от `product_id`.
3. **3NF.** Транзитивные зависимости: `client_id → client_name, client_city` (в условии приведено `client_name → client_city`), `product_id → product_name, unit_price`.
4. **Аномалии:**

| Аномалия | Что происходит в «плохой» таблице | Как исправляется в 3NF |
|----------|-----------------------------------|------------------------|
| Обновления | Смена города клиента 101 только в продаже 5001 даёт «Москва» и «Сочи» одновременно | Город хранится один раз в `clients`, достаточно одного `UPDATE` |
| Удаления | Удаление продаж 5004 и 5006 полностью стирает клиента 103 | Клиент остаётся в `clients` после удаления всех его продаж |
| Вставки | Нового клиента без продажи можно добавить только строкой с `NULL` в полях продажи | `INSERT INTO clients (...)` работает без продаж |

## 3. Целевая схема (3NF)

| Таблица | Назначение | Ключ |
|---------|-----------|------|
| `clients` | клиенты (`client_id`, `client_name`, `client_city`) | PK `client_id` |
| `products` | товары (`product_id`, `product_name`, `unit_price`) | PK `product_id` |
| `sales` | шапки продаж (`sale_id`, `sale_date`, `client_id`) | PK `sale_id`, FK → `clients` |
| `sale_items` | позиции (`sale_id`, `product_id`, `quantity`) | PK `(sale_id, product_id)`, FK → `sales`, `products` |

## 📋 4. Шаги выполнения

1. `bash commands.sh` поднимает контейнер, очищает лог, выполняет скрипты и выгружает артефакты.
2. `01_schema.sql` создаёт БД, исходную и четыре пустые нормализованные таблицы.
3. `02_seed.sql` загружает 10 исходных строк в `sales_unnormalized`.
4. `03_queries.sql`: `INSERT ... SELECT` перенос, проверки, демонстрация аномалий
   в транзакции с `ROLLBACK`, затем `DROP TABLE sales_unnormalized`.
5. Заполнить разделы 5 и 6 реальными результатами и скриншотами.

Ручной ввод SQL (если нужно, чтобы лог содержал набранные команды):

```bash
docker exec -it imfua-07-normalization-2 mysql --default-character-set=utf8mb4 -uroot -proot
```

## 📊 5. Результаты проверок (реальный запуск)

| Проверка | Ожидаемое значение | Фактический результат |
|----------|--------------------|------------------------|
| `SUM(unit_price * quantity)` до нормализации | 80 000.00 | `total_old = 80000.00` |
| `SUM(p.unit_price * si.quantity)` после нормализации | 80 000.00 | `total_new = 80000.00` |
| Продаж: `DISTINCT sale_id` / `COUNT(*) FROM sales` | 6 / 6 | `old_sales = 6`, `new_sales = 6` |
| Клиентов: `DISTINCT client_id` / `COUNT(*) FROM clients` | 3 / 3 | `old_clients = 3`, `new_clients = 3` |
| Товаров: `DISTINCT product_id` / `COUNT(*) FROM products` | 5 / 5 | `old_products = 5`, `new_products = 5` |
| Позиций: исходных / `COUNT(*) FROM sale_items` | 10 / 10 | `old_items = 10`, `new_items = 10` |
| «Сколько потратил клиент 101?» | 37 000.00 | `101	Иванов Иван	37000.00` (до и после переноса); полный вывод смотри в [execution-output.txt](artifacts/execution-output.txt) |
| Аномалии после 3NF | клиент и цена товара хранятся по одному разу, клиент без продажи возможен | В «плохой» таблице client 101 даёт `Сочи` и `Москва` одновременно; в `clients` после `UPDATE` одна строка `101	Иванов Иван	Сочи`; после удаления продаж 5004/5006 клиент 103 остаётся (`103	Сидоров Алексей	Казань`); `104	Новый клиент	Тверь` добавлен без продаж |

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general-лог MariaDB 11.4.14 (7432 байт).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованный лог выполненных SQL-команд (143 строки).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод `01_schema.sql`, `02_seed.sql`, `03_queries.sql`.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — коды возврата `0, 0, 0`, ошибок 0.
- [artifacts/sales_norm-dump.sql](artifacts/sales_norm-dump.sql) — дамп базы `sales_norm` (4858 байт).

Скриншоты в `evidence/` не создавались (нет GUI); их роль выполняют логи и вывод запросов.

## 📸 6. Места под скриншоты (`evidence/`)

| № | Что снимаем | Файл | Статус |
|---|-------------|------|--------|
| 1 | Исходная таблица `SELECT * FROM sales_unnormalized` | `evidence/01-source-table.png` | `не создавался (нет GUI)` |
| 2 | Четыре созданные таблицы (`SHOW TABLES`, `DESCRIBE`) | `evidence/02-schema.png` | `не создавался (нет GUI)` |
| 3 | Результат `INSERT ... SELECT` и данные справочников | `evidence/03-migration.png` | `не создавался (нет GUI)` |
| 4 | Сравнение сумм и количеств | `evidence/04-checks.png` | `не создавался (нет GUI)` |
| 5 | Демонстрация аномалий и их исчезновения | `evidence/05-anomalies.png` | `не создавался (нет GUI)` |
| 6 | Лог действий без служебных записей | `evidence/06-log.png` | `не создавался (нет GUI)` |

## 📎 7. Артефакты

| Путь | Содержимое |
|------|------------|
| `artifacts/general.log` | сырой general-лог локального MariaDB 11.4.14 |
| `artifacts/my_actions.log` | отфильтрованный лог только действий пользователя |
| `artifacts/execution-output.txt` | реальный вывод всех трёх SQL-скриптов |
| `artifacts/RESULT.txt` | сводка: коды возврата `0, 0, 0`, ошибок 0 |
| `artifacts/sales_norm-dump.sql` | дамп нормализованной базы после проверок |

Перечисленные файлы реально находятся в `artifacts/`; дампа «до переноса» нет, каталог `evidence/` пуст (скриншоты не создавались, нет GUI).

## ✅ 8. Чек-лист сдачи

- [x] `my.cnf` совпадает с `database/_shared/my.cnf`, UTF-8 без BOM, LF.
- [x] Скрипты выполнены по порядку: `01_schema.sql`, `02_seed.sql`, `03_queries.sql`.
- [x] Суммы и количества до/после переноса совпадают.
- [x] Показаны все три аномалии и их исчезновение в 3NF.
- [x] Старая таблица `sales_unnormalized` удалена в конце.
- [x] `artifacts/my_actions.log` содержит только осмысленные SQL-команды.
- [x] Дамп базы находится в `artifacts/`.
- [x] В раздел 5 вставлены реальные результаты; скриншоты не создавались (нет GUI).

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
