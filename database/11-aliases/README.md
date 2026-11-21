# Лабораторная 11 — алиасы в MySQL

**Оригинал:** [Aliases.md — Учебное руководство по алиасам в SQL (с созданием БД и логированием)](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Aliases.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/Aliases.md`

> ⚠️ **Статус отчёта.** В этой среде нет Docker/MySQL, поэтому реальные `general.log`,
> `my_actions.log`, дампы и скриншоты **не генерируются здесь** — они создаются при
> запуске на вашей машине (WSL / Git-Bash + Docker CLI). Ниже — готовый шаблон отчёта:
> заполните `<...>` реальными значениями и вставьте снимки в `evidence/`.

## Цель

Освоить алиасы таблиц и столбцов, понять порядок выполнения запроса и зоны видимости
алиаса (`WHERE` — нельзя, `ORDER BY` — можно, `GROUP BY`/`HAVING` — можно в MySQL),
научиться использовать алиасы в самосоединениях, производных таблицах и подзапросах,
а также вести и фильтровать `general.log` и делать дамп базы `alias_db`.

## Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf`: UTF-8, `general_log = 1`, `log_output = FILE` |
| `01_schema.sql` | `CREATE DATABASE alias_db`, таблицы `customers`, `orders`, `employees` |
| `02_seed.sql` | Данные из раздела 0.5 инструкции (5 клиентов, 6 заказов, 6 сотрудников) + проверки |
| `03_queries.sql` | Разделы 1–9: алиасы таблиц/столбцов, самосоединение, подзапросы, JOIN, «до/после», ошибочные примеры (комментариями) |
| `commands.sh` | `docker run`, очистка лога, вызов SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Пустые каталоги для артефактов и скриншотов |

## Пошаговое выполнение

```bash
cd imfua-practice
make check                              # статическая проверка структуры
bash database/11-aliases/commands.sh    # поднимает контейнер imfua-11-aliases и выполняет всё
```

Скрипт делает по шагам (соответствуют разделам 0.2–0.5, 10, 11 инструкции):

1. Удаляет старый контейнер `imfua-11-aliases` и его volume (не `docker volume prune -a`).
2. Копирует эталонный `my.cnf` в каталог задания.
3. `docker run ... -e MYSQL_ROOT_PASSWORD=123 -e LANG=C.UTF-8 -e MYSQL_INITDB_SKIP_TZINFO=1 \
   -v <volume>:/var/lib/mysql -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Ждёт готовности MySQL и проверяет `SHOW VARIABLES LIKE 'general_log'`, `log_output`.
5. Очищает лог: `docker exec -u mysql imfua-11-aliases sh -c ': > /var/lib/mysql/general.log'`.
6. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql`.
7. Выгружает лог и делает дамп:
   `bash scripts/export-log.sh 11-aliases`, `bash scripts/dump-db.sh 11-aliases alias_db`.

Интерактивный вариант (как прямо в инструкции — в лог попадут именно ваши действия):

```bash
docker exec -it imfua-11-aliases mysql --default-character-set=utf8mb4 -uroot -p   # пароль 123
# выполняйте запросы из 01_schema.sql / 02_seed.sql / 03_queries.sql вручную
\q
docker exec imfua-11-aliases ls -la /var/lib/mysql/general.log
docker exec imfua-11-aliases tail -n 30 /var/lib/mysql/general.log
```

Логирование вручную по разделу 10 инструкции (вместо `export-log.sh` можно выполнить
точно эти команды; скрипт делает аналогичную фильтрацию):

```shell
docker exec -it imfua-11-aliases mysql --default-character-set=utf8mb4 -uroot -p   # затем \q
docker exec imfua-11-aliases ls -la /var/lib/mysql/general.log
docker exec imfua-11-aliases tail -n 30 /var/lib/mysql/general.log
docker exec imfua-11-aliases cat /var/lib/mysql/general.log \
  | grep -E "Query[[:space:]]+(CREATE|INSERT|SELECT|UPDATE|DELETE|ALTER|DROP|RENAME|DESCRIBE|EXPLAIN|SHOW DATABASES|SHOW TABLES|SHOW FULL TABLES|SHOW CREATE|SHOW VARIABLES LIKE)" \
  | grep -v -E "INSERT INTO help_|INSERT INTO time_zone|INSERT INTO mysql\.|SELECT \* FROM mysql\.general_log" \
  > my_actions.log
docker cp imfua-11-aliases:/var/lib/mysql/general.log ./general.log
docker exec -u mysql imfua-11-aliases sh -c ': > /var/lib/mysql/general.log'   # очистка
```

Запросы из раздела 7 инструкции (ссылка на старое имя таблицы, пропущенный `AS`,
алиас в `WHERE`, неоднозначный `id`, пропущенный алиас в самосоединении) намеренно
ошибочные — в `03_queries.sql` они оставлены комментариями с пометкой
`НЕ ВЫПОЛНЯТЬ`, рядом даны исправленные варианты.

## Результаты: EXPLAIN «до/после»

Алиасы не меняют план: запрос из раздела 2 без алиасов и тот же запрос с алиасами
должны дать одинаковые `type`/`rows`/`Extra`. Заполните таблицу реальными значениями
из вашего `EXPLAIN` (скриншоты — в `evidence/`).

| № | Запрос | До (aliases нет): `type / rows / Extra` | После (с алиасами): `type / rows / Extra` |
|---|--------|------------------------------------------|-------------------------------------------|
| 1 | `EXPLAIN SELECT customers.name, orders.order_date, orders.amount FROM customers JOIN orders ON customers.id = orders.customer_id;` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` |
| 2 | `EXPLAIN SELECT c.name, o.order_date, o.amount FROM customers c JOIN orders o ON c.id = o.customer_id;` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` |
| 3 | `EXPLAIN SELECT c.name ... JOIN (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id) o ...` | `<type>` / `<rows>` / `<Extra>` | `<type>` / `<rows>` / `<Extra>` |

Ожидаемая интерпретация: `type = <ref/ALL/index>`, `rows = <...>`, `Extra = <...>`;
главное — различий между «до» и «после» нет, меняется только читаемость SQL.

Дополнительно проверьте результаты запросов (впишите реальные значения):

| Проверка | Ожидаемый результат | Фактический результат |
|----------|---------------------|------------------------|
| `SELECT * FROM customers;` | 5 строк | `<вставить>` |
| `SELECT * FROM orders;` | 6 строк | `<вставить>` |
| `SELECT * FROM employees;` | 6 строк, у Анны Петровой `manager_id = NULL` | `<вставить>` |
| Самосоединение `e/m` | 5 пар «сотрудник — руководитель» | `<вставить>` |
| `ORDER BY double_amount DESC` | 6 заказов, максимум `4200.00 * 2` | `<вставить>` |
| `SELECT * FROM (...) AS t` | 4 строки с `customer_id, total` | `<вставить>` |

## Места под скриншоты (создаются при запуске)

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-schema-and-seed.png` | `SHOW TABLES` и первые строки `customers`, `orders`, `employees` |
| `evidence/02-aliases-join.png` | Результат запроса с алиасами таблиц |
| `evidence/03-self-join.png` | Результат самосоединения `employees e / m` |
| `evidence/04-column-aliases.png` | `order_count`, `total_amount`, `double_amount` |
| `evidence/05-explain-before-after.png` | Два `EXPLAIN` из таблицы выше |
| `evidence/06-log-and-dump.png` | `ls -la general.log`, `head my_actions.log`, `head <dump>` |

> Файлы в `evidence/` игнорируются Git; коммитится только `evidence/.gitkeep`.

## Артефакты

Цепочка: `general.log` (внутри контейнера `/var/lib/mysql/general.log`)
→ `artifacts/general.log` (полный) → `artifacts/my_actions.log` (только ваши действия).

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Копия полного general.log (`docker cp`) | Создаётся при запуске |
| `artifacts/my_actions.log` | Отфильтрованный лог (`CREATE/INSERT/SELECT/UPDATE/...`, без `Connect`, `Quit`, `SET NAMES`, help/time_zone) | Создаётся при запуске |
| `artifacts/alias_db-dump.sql` | Дамп базы `alias_db` с таблицами `customers`, `orders`, `employees` | Создаётся при запуске |
| `database/logs/11-aliases-actions.log` | Копия отфильтрованного лога | Создаётся при запуске |
| `database/dumps/11-aliases-alias_db-dump.sql` | Копия дампа | Создаётся при запуске |

В репозитории лежат только `artifacts/.gitkeep` и `evidence/.gitkeep`; реальные логи,
дампы и PNG появляются на машине с Docker/MySQL и в Git не коммитятся.

## Чек-лист сдачи

- [ ] Контейнер `imfua-11-aliases` поднят с `my.cnf` без BOM/LF-переводов.
- [ ] Лог очищен **до** начала работы (`-u mysql`).
- [ ] Выполнены все три SQL-файла; ошибочные примеры остались комментариями.
- [ ] Таблица EXPLAIN «до/после» заполнена реальными `type`, `rows`, `Extra`.
- [ ] Скриншоты добавлены в `evidence/` (не коммитятся, но есть локально).
- [ ] `artifacts/my_actions.log` содержит только осмысленные SQL-команды.
- [ ] `artifacts/alias_db-dump.sql` содержит три таблицы с данными.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.
