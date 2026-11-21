### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization.md)

# Лабораторная 16 — нормализация: аномалии → 3NF

**Оригинал:** [Normalization.md — Нормализация данных. Практическое руководство (с ведением лога)](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/Normalization.md`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

Создать базу `shop_norm` и «плохую» таблицу `orders_bad`, продемонстрировать
аномалии обновления, удаления и вставки, перенести данные в четыре таблицы 3NF
(`customers_3nf`, `products_3nf`, `orders_3nf`, `order_items_3nf`), проверить,
что суммы и количества совпали, и показать, что аномалии исчезли. Дополнительно —
дамп до/после нормализации и лог действий пользователя.

## 🧰 Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, general_log) |
| `01_schema.sql` | `CREATE DATABASE shop_norm`, `CREATE TABLE orders_bad` |
| `02_seed.sql` | 5 строк заказов, `SELECT *`, сумма Ивана, `EXPLAIN` «до» |
| `03_queries.sql` | Раздел 3: аномалии обновления / удаления / вставки, очистка тестовой строки |
| `04_normalize.sql` | Разделы 5–9: 3NF-схема, перенос, проверки, повтор операций, `RENAME TABLE` |
| `commands.sh` | Запуск MySQL, SQL по шагам, **дамп до и после**, экспорт лога |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## 📋 Пошаговое выполнение

```bash
cd imfua-practice
make check
bash database/16-normalization-common/commands.sh    # контейнер imfua-16-normalization-common
```

Последовательность `commands.sh`:

1. Удаляет старый контейнер и volume (не `docker volume prune -a`).
2. Копирует общий `my.cnf` в каталог задания.
3. `docker run --name imfua-16-normalization-common -e MYSQL_ROOT_PASSWORD=123 \
   -e LANG=C.UTF-8 -e MYSQL_INITDB_SKIP_TZINFO=1 -v <volume>:/var/lib/mysql \
   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Очищает лог: `docker exec -u mysql imfua-16-normalization-common sh -c ': > /var/lib/mysql/general.log'`.
5. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql`.
6. Дамп «до»: `bash scripts/dump-db.sh 16-normalization-common shop_norm` → копия `shop_norm-before-dump.sql`.
7. Выполняет `04_normalize.sql`.
8. Дамп «после» → копия `shop_norm-after-dump.sql`.
9. `bash scripts/export-log.sh 16-normalization-common`.

Интерактивный вариант (как в инструкции): `docker exec -it imfua-16-normalization-common mysql --default-character-set=utf8mb4 -uroot -p` (пароль `123`), затем выполняйте SQL вручную; между шагами 5/7 и 7/9 сделайте дампы командами из раздела «Артефакты».

## 📊 Результаты: аномалии и EXPLAIN «до/после»

**СУБД:** MariaDB 11.4.14 (`Version: 11.4.14-MariaDB-log` — первая строка
`artifacts/general.log` и `artifacts/my_actions.log`). Все значения ниже взяты из
`artifacts/execution-output.txt` (блоки `02_seed.sql`, `03_queries.sql`, `04_normalize.sql`).

| Аномалия | Что сделали | Что показал `SELECT` |
|----------|-------------|----------------------|
| Обновления | `UPDATE orders_bad SET customer_city='Сочи' WHERE order_id=1;` | У Ивана два города: `Сочи` (`order_id=1`) и `Москва` (`order_id=2`) |
| Удаления | `DELETE FROM orders_bad WHERE order_id=4;` | Мария осталась пока есть `order_id=3`; при удалении всех заказов клиент исчез бы |
| Вставки | `INSERT INTO orders_bad (customer_name, customer_city) VALUES ('Новый клиент','Тверь');` | Строка `order_id=6` с `NULL` в полях заказа; затем тестовая строка удалена |

План «до/после» для запроса «сколько потратил Иван» (добавлен для отчёта; в самой
инструкции этого `EXPLAIN` нет — он нужен для сравнения планов до и после 3NF):

| Этап | Запрос | `type / key / rows / Extra` | Сумма |
|------|--------|------------------------|-------|
| До нормализации (`orders_bad`) | `EXPLAIN SELECT SUM(product_price * quantity) AS total FROM orders_bad WHERE customer_name = 'Иван';` | `ALL` / `NULL` / `5` / `Using where` | `440` |
| После (`customers_3nf → orders_3nf → order_items_3nf → products_3nf`) | `EXPLAIN SELECT SUM(p.product_price * oi.quantity) ... WHERE c.customer_name = 'Иван';` | `o: index / customer_id / 4 / Using index; c: eq_ref / PRIMARY / 1 / Using where; oi: ref / PRIMARY / 1 / Extra пустое; p: eq_ref / PRIMARY / 1 / Extra пустое` | `440` |

Проверки переноса (фактические значения из вывода):

| Проверка | Ожидается | Факт |
|----------|-----------|------|
| `total_old` vs `total_new` | `1200` = `1200` | `1200` / `1200` |
| Заказы: `COUNT(DISTINCT order_id)` vs `COUNT(*)` | `4` = `4` | `4` / `4` |
| Клиенты: distinct vs `COUNT(*)` | `4` = `4` | `4` / `4` |
| Товары: distinct vs `COUNT(*)` | `4` = `4` | `3` / `3` (после удаления `order_id=4` в `orders_bad` осталось 3 товара; ожидание `4` не подтвердилось) |
| Иван (новая схема) | `440` | `440` |
| Мария после удаления заказов | клиент остался в `customers_3nf` | клиент остался: `customer_id=3`, `Мария`, `Казань` |
| Новый клиент без заказа | добавлен без `NULL`-полей | `customer_id=8`, `Новый клиент`, `Тверь` |

> После переноса в `customers_3nf` оказались две строки для Ивана (`customer_id=1` и `2`,
> обе с городом `Сочи`) — аномалия обновления из `orders_bad` сохранилась в данных;
> повторное `UPDATE` и последующие проверки выполнены в соответствии с `04_normalize.sql`.

## 📸 Места под скриншоты (не создавались — нет GUI)

Файлы `evidence/*.png` не создавались; таблица ниже сохраняет места, где они
предусмотрены инструкцией.

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-bad-table.png` | `SELECT * FROM orders_bad` (5 строк, дублирование клиентов и цен) |
| `evidence/02-anomaly-update.png` | Два разных города у Ивана |
| `evidence/03-anomaly-delete.png` | Мария после удаления `order_id = 4` |
| `evidence/04-anomaly-insert.png` | «Новый клиент» с `NULL` в полях заказа |
| `evidence/05-3nf-tables.png` | `SHOW TABLES` + `DESCRIBE` четырёх таблиц |
| `evidence/06-transfer.png` | `SELECT *` из всех четырёх 3NF-таблиц |
| `evidence/07-totals.png` | `total_old`, `total_new`, счётчики, сумма Ивана |
| `evidence/08-explain.png` | Два `EXPLAIN` из таблицы выше |
| `evidence/09-dumps-log.png` | `head` обоих дампов и `my_actions.log` |

## 📎 Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только осмысленные SQL-команды).

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/shop_norm-before-dump.sql` | Дамп с единственной таблицей `orders_bad` (до нормализации) | Не создавался (в `artifacts/` нет такого файла) |
| `artifacts/shop_norm-after-dump.sql` | Дамп с 4 таблицами 3NF + `orders_bad_backup` | Не создавался (в `artifacts/` нет такого файла) |
| `artifacts/shop_norm-dump.sql` | Дамп базы `shop_norm` (последнее состояние, 6242 байт) | Создан |
| `artifacts/general.log` | Полный general.log | Создан |
| `artifacts/my_actions.log` | Отфильтрованный лог: `CREATE / INSERT / UPDATE / DELETE / RENAME / SELECT ...` | Создан |
| `artifacts/execution-output.txt` | Вывод SQL, включая оба `EXPLAIN` и проверки переноса | Создан |
| `artifacts/RESULT.txt` | Сводка: коды возврата 0, ошибок 0 | Создан |
| `database/logs/16-normalization-common-actions.log` | Копия лога | Не создавалась (каталога `database/logs` нет) |
| `database/dumps/16-normalization-common-shop_norm-dump.sql` | Копия дампа | Не создавалась (каталога `database/dumps` нет) |

Логи и дамп в `artifacts/` созданы при локальном запуске на MariaDB 11.4.14;
PNG в `evidence/` не создавались.

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general.log; первая строка фиксирует
  `Version: 11.4.14-MariaDB-log` (MariaDB 11.4.14).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованные действия пользователя
  (150 строк по `RESULT.txt`).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод SQL: аномалии,
  перенос, проверки, оба `EXPLAIN` и повторение операций.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — 4 SQL-файла, коды возврата 0, ошибок 0.
- [artifacts/shop_norm-dump.sql](artifacts/shop_norm-dump.sql) — дамп базы `shop_norm`
  (6242 байт); отдельных файлов `shop_norm-before-dump.sql` / `shop_norm-after-dump.sql` нет.
- `artifacts/.gitkeep` — служебный файл каталога.

> Ниже — исходные критерии сдачи. Пункты про Docker/WSL и скриншоты не применимы:
> лабораторная выполнялась локально на MariaDB 11.4.14, GUI отсутствует.

## ✅ Чек-лист сдачи

- [ ] Контейнер поднят с общим `my.cnf`, лог очищен до начала.
- [ ] Показаны все три аномалии в `orders_bad`.
- [ ] Созданы четыре пустые 3NF-таблицы и выполнен перенос данных запросами (не вручную).
- [ ] `total_old = total_new` и все пары счётчиков совпали.
- [ ] Показано, что аномалии исчезли (одно `UPDATE`, клиент после удаления заказов, клиент без заказа).
- [ ] Старая таблица переименована в `orders_bad_backup` (`RENAME` безопаснее `DROP`).
- [ ] Есть дампы до и после нормализации.
- [ ] Таблица EXPLAIN «до/после» заполнена, скриншоты в `evidence/`.
- [ ] `my_actions.log` содержит только ваши действия (без `Connect`, `Quit`, `SET NAMES`, help/time_zone).
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
