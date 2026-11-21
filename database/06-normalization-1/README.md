### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_1.md)

# Лабораторная № 1 по нормализации: `sales_unnormalized_2` → 3NF

- **Оригинал:** [Normalization_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_1.md)
- **Каталог:** `database/06-normalization-1`
- **Контейнер:** `imfua-06-normalization-1`
- **База данных:** `sales_norm`
- **Порядок файлов:** `01_schema.sql` → `02_seed.sql` → `03_queries.sql`; запуск — `commands.sh`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 1. Цель

1. Создать базу `sales_norm` и «плохую» таблицу `sales_unnormalized_2` с исходными строками.
2. Продемонстрировать аномалии обновления, удаления и вставки.
3. Привести данные к третьей нормальной форме (3NF), разбив на 4 таблицы.
4. Перенести данные из исходной таблицы в 3NF через `INSERT ... SELECT`.
5. Проверить, что данные не потерялись (суммы и количества), и показать, что аномалии исчезли.
6. Сделать дамп до и после нормализации, выгрузить отфильтрованный лог действий.

## 2. Исходная ненормализованная таблица

`CREATE TABLE sales_unnormalized_2` (строки строго из инструкции, `02_seed.sql`):

| report_id | report_date | customer_id | customer_name | product_id | product_name | price | quantity |
|-----------|-------------|-------------|---------------|------------|--------------|-------|----------|
| 1101 | 2026-03-05 | 12 | Дания | 101 | Дыни | 800 | 1100 |
| 1101 | 2026-03-05 | 12 | Дания | 102 | Клубника | 150 | 300 |
| 1102 | 2026-03-07 | 23 | Испания | 103 | Яблоки | 120 | 1700 |
| 1103 | 2026-03-08 | 25 | Албания | 104 | Лимоны | 200 | 500 |
| 1104 | 2026-03-10 | 12 | Дания | 101 | Дыни | 800 | 2500 |
| 1105 | 2026-03-12 | 25 | Албания | 103 | Яблоки | 120 | 2000 |
| 1105 | 2026-03-12 | 25 | Албания | 104 | Лимоны | 200 | 700 |

Даты в оригинале записаны как `05.03`, `07.03` и т. д.; в SQL используется тип `DATE` с годом `2026`, как в остальных заданиях курса.

### Нарушения

1. **Повторяющиеся группы.** Для отчёта 1101 и 1105 данные покупателя и дата продублированы в каждой строке товара.
2. **2NF.** Потенциальный ключ — `(report_id, product_id)`; `report_date`, `customer_id`, `customer_name` зависят только от `report_id`, а `product_name`, `price` — только от `product_id`.
3. **3NF.** Транзитивные зависимости: `customer_id → customer_name`, `product_id → product_name, price`.
4. **Аномалии:**

| Аномалия | Что происходит в «плохой» таблице | Как исправляется в 3NF |
|----------|-----------------------------------|------------------------|
| Обновления | Смена имени покупателя в одной строке отчёта 1101 оставляет старое имя в строке 1104 | Имя хранится один раз в `customers`, достаточно одного `UPDATE` |
| Удаления | Удаление отчётов 1101 и 1104 полностью стирает покупателя 12 из базы | Покупатель остаётся в `customers` после удаления его отчётов |
| Вставки | Покупателя без отчёта нельзя добавить без `NULL` в полях отчёта/товара | `INSERT INTO customers (...)` работает без существования отчёта |

## 3. Целевая схема (3NF)

| Таблица | Назначение | Ключ |
|---------|-----------|------|
| `customers` | справочник покупателей (`customer_id`, `customer_name`) | PK `customer_id` |
| `products` | справочник товаров (`product_id`, `product_name`, `price`) | PK `product_id` |
| `reports` | шапки отчётов (`report_id`, `report_date`, `customer_id`) | PK `report_id`, FK → `customers` |
| `report_items` | позиции (`report_id`, `product_id`, `quantity`) | PK `(report_id, product_id)`, FK → `reports`, `products` |

Порядок создания и переноса: `customers`, `products` → `reports` → `report_items`.

## 📋 4. Шаги выполнения

1. `bash commands.sh` поднимает контейнер, очищает лог, выполняет скрипты по порядку и выгружает артефакты.
2. `01_schema.sql` создаёт БД, исходную и четыре нормализованные таблицы (пустые).
3. `02_seed.sql` загружает 7 исходных строк в `sales_unnormalized_2`.
4. `03_queries.sql` переносит данные (`INSERT ... SELECT`), выполняет проверки,
   демонстрирует аномалии и исчезновение аномалий (в транзакции с `ROLLBACK`,
   чтобы не испортить данные), затем удаляет старую таблицу.
5. Результаты и скриншоты вставляются в этот отчёт; логи и дампы лежат в `artifacts/`.

Ручной вариант (если нужно, чтобы в лог попали именно набранные команды):

```bash
docker exec -it imfua-06-normalization-1 mysql --default-character-set=utf8mb4 -uroot -proot
```

## 📊 5. Результаты проверок (реальный запуск)

| Проверка | Ожидаемое значение | Фактический результат |
|----------|--------------------|------------------------|
| `SUM(price * quantity)` до нормализации | 3 609 000.00 | `total_old = 3609000.00` |
| `SUM(p.price * ri.quantity)` после нормализации | 3 609 000.00 | `total_new = 3609000.00` |
| Отчётов: `COUNT(DISTINCT report_id)` / `COUNT(*) FROM reports` | 5 / 5 | `old_reports = 5`, `new_reports = 5` |
| Покупателей: `DISTINCT` / `COUNT(*) FROM customers` | 3 / 3 | `old_customers = 3`, `new_customers = 3` |
| Товаров: `DISTINCT` / `COUNT(*) FROM products` | 4 / 4 | `old_products = 4`, `new_products = 4` |
| Позиций: исходных / `COUNT(*) FROM report_items` | 7 / 7 | `old_items = 7`, `new_items = 7` |
| «Сколько потратил покупатель 12?» | 2 925 000.00 | `12	Дания	2925000.00` (до и после переноса); полный вывод смотри в [execution-output.txt](artifacts/execution-output.txt) |
| Аномалии после 3NF | имя покупателя и цена товара хранятся в одной строке; покупатель без отчёта возможен | `UPDATE` имени покупателя 12 даёт `12	Дания (новое имя)` и в `customers`, и в соединении; после удаления отчётов 1101/1104 покупатель 12 остаётся; `99	Новый покупатель` добавлен без отчёта |

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general-лог MariaDB 11.4.14 (6854 байт).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованный лог выполненных SQL-команд (138 строк).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод `01_schema.sql`, `02_seed.sql`, `03_queries.sql`.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — коды возврата `0, 0, 0`, ошибок 0.
- [artifacts/sales_norm-dump.sql](artifacts/sales_norm-dump.sql) — дамп базы `sales_norm` (4583 байт).

Скриншоты в `evidence/` не создавались (нет GUI); их роль выполняют логи и вывод запросов.

## 📸 6. Места под скриншоты (`evidence/`)

| № | Что снимаем | Файл | Статус |
|---|-------------|------|--------|
| 1 | Исходная таблица `SELECT * FROM sales_unnormalized_2` | `evidence/01-source-table.png` | `не создавался (нет GUI)` |
| 2 | Четыре созданные таблицы (`SHOW TABLES`, `DESCRIBE`) | `evidence/02-schema.png` | `не создавался (нет GUI)` |
| 3 | Результат `INSERT ... SELECT` и данные справочников | `evidence/03-migration.png` | `не создавался (нет GUI)` |
| 4 | Сравнение сумм и количества | `evidence/04-checks.png` | `не создавался (нет GUI)` |
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
- [x] Суммы до и после переноса совпадают, количества совпадают.
- [x] Показаны все три аномалии и их исчезновение в 3NF.
- [x] Старая таблица `sales_unnormalized_2` удалена в конце.
- [x] `artifacts/my_actions.log` содержит только осмысленные SQL-команды.
- [x] Дамп базы находится в `artifacts/`.
- [x] В раздел 5 вставлены реальные результаты; скриншоты не создавались (нет GUI).

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
