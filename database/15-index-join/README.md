# Лабораторная 15 — индексы и JOIN

**Оригинал:** [Index_JOIN.md — Индексы и `JOIN`: оптимизация соединений в MySQL](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index_JOIN.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/Index_JOIN.md`

> ⚠️ **Статус отчёта.** В этой среде нет Docker/MySQL: реальные логи, дампы и
> скриншоты создаются **при запуске на вашей машине** (инструкция требует WSL).
> Плейсхолдеры `<...>` заменяются реальными значениями из вашего `EXPLAIN`.

## Цель

Показать, почему `JOIN` без индекса на столбце соединения даёт `type: ALL` и полный
перебор; создать `idx_user_id` и получить `ref`; разобрать автоматическое создание
индекса для `FOREIGN KEY`, порядок соединения (driving table), составной индекс
`(join_col, filter_col)` и разницу `INNER JOIN` / `LEFT JOIN`.

## Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, general_log) |
| `01_schema.sql` | `CREATE DATABASE join_practice`, таблицы `users` и `orders` **без FK и без индекса** на `user_id` |
| `02_seed.sql` | 50 пользователей + 500 заказов через `INSERT ... SELECT`, проверки `COUNT(*)` |
| `03_queries.sql` | Эксперименты 1–2, порядок соединения, составной индекс, INNER/LEFT, `EXPLAIN FORMAT=TREE` |
| `04_fk_demo.sql` | Отдельная таблица `orders_fk` с `CONSTRAINT fk_orders_user` — авто-индекс InnoDB |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## Пошаговое выполнение

```bash
cd imfua-practice
make check
bash database/15-index-join/commands.sh     # контейнер imfua-15-index-join
```

Шаги `commands.sh`:

1. Удаляет старый контейнер/volume (без `docker volume prune -a`).
2. Копирует общий `my.cnf` в каталог задания.
3. `docker run --name imfua-15-index-join -e MYSQL_ROOT_PASSWORD=123 \
   -e LANG=C.UTF-8 -e MYSQL_INITDB_SKIP_TZINFO=1 -v <volume>:/var/lib/mysql \
   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Ждёт MySQL, проверяет `general_log` и `log_output`.
5. Очищает лог: `docker exec -u mysql imfua-15-index-join sh -c ': > /var/lib/mysql/general.log'`.
6. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql` → `04_fk_demo.sql`.
7. `bash scripts/export-log.sh 15-index-join` и `bash scripts/dump-db.sh 15-index-join join_practice`.

Интерактивно: `docker exec -it imfua-15-index-join mysql --default-character-set=utf8mb4 -uroot -p` (пароль `123`).

## Результаты: EXPLAIN «до/после»

| № / эксперимент | Запрос | До: `table / type / key / rows / Extra` | После: `table / type / key / rows / Extra` |
|-----------------|--------|------------------------------------------|---------------------------------------------|
| 1. Без индекса | `EXPLAIN SELECT o.id, o.amount, u.name FROM orders o JOIN users u ON o.user_id = u.id WHERE u.vip_level = 3;` | `u: <...>`; `o: <type>/<key>/<rows>/<Extra>` (инструкция: `ALL / NULL / 500 / Using where; Using join buffer`) | — |
| 2. `CREATE INDEX idx_user_id ON orders(user_id);` | тот же `EXPLAIN` | `u: <...>`; `o: <...>` | `u: <...>`; `o: <type>/<key>/<rows>/<Extra>` (ожидается `ref / idx_user_id / ~10 / Using where`) |
| 3. Порядок соединения | тот же `EXPLAIN`, первая строка | `<первая таблица>` — driving table | `<первая таблица>`; с `STRAIGHT_JOIN`: `<первая таблица>` |
| 4. Составной индекс | `... WHERE u.vip_level = 3 AND o.status = 'paid';` | `<type>/<key>/<rows>/<Extra>` | `<type>/<key>/<rows>/<Extra>` (ожидается `idx_user_status`, меньше `rows`) |
| 5. INNER JOIN | `EXPLAIN SELECT ... INNER JOIN users u ... WHERE u.vip_level = 3;` | `<таблицы в порядке соединения>` | `<type/key/rows/Extra>` |
| 5. LEFT JOIN | `EXPLAIN SELECT ... LEFT JOIN users u ... WHERE u.vip_level = 3;` | `<...>` (фильтр превращает LEFT в INNER) | `<...>` |
| 5. LEFT JOIN без WHERE | `EXPLAIN SELECT ... LEFT JOIN users u ON o.user_id = u.id;` | `<...>` (orders — слева, фиксирован) | `<...>` |
| FK (04_fk_demo) | `SHOW INDEX FROM orders_fk` + `EXPLAIN SELECT ... FROM orders_fk f JOIN users u ...` | — | `<Key_name>` / `<type>` / `<key>`: авто-индекс по `user_id`, `ref` |

Проверка объёмов: `SELECT COUNT(*) FROM users;` → `<50>`, `SELECT COUNT(*) FROM orders;` → `<500>`,
`SELECT COUNT(*) FROM orders_fk;` → `<500>`.

## Места под скриншоты (создаются при запуске)

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-counts.png` | `COUNT(*)` = 50 / 500 |
| `evidence/02-join-before.png` | `EXPLAIN` до `idx_user_id`: `type: ALL`, `Using join buffer` |
| `evidence/03-show-index.png` | `SHOW INDEX FROM orders` (PRIMARY, idx_user_id, idx_user_status) |
| `evidence/04-join-after.png` | Тот же `EXPLAIN` после индекса: `ref`, `idx_user_id` |
| `evidence/05-join-order.png` | `EXPLAIN` + `STRAIGHT_JOIN` — сравнение порядка таблиц |
| `evidence/06-composite.png` | `EXPLAIN` с `idx_user_status` и результат запроса |
| `evidence/07-fk-auto-index.png` | `SHOW INDEX FROM orders_fk` и `EXPLAIN` с FK |
| `evidence/08-inner-left.png` | `EXPLAIN` для INNER JOIN и LEFT JOIN |
| `evidence/09-log-dump.png` | `head artifacts/my_actions.log`, `head artifacts/join_practice-dump.sql` |

## Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только ваши SQL-действия).

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создаётся при запуске |
| `artifacts/my_actions.log` | Отфильтрованный лог | Создаётся при запуске |
| `artifacts/join_practice-dump.sql` | Дамп `users`, `orders`, `orders_fk`, индексы `idx_user_id`, `idx_user_status` | Создаётся при запуске |
| `database/logs/15-index-join-actions.log` | Копия лога | Создаётся при запуске |
| `database/dumps/15-index-join-join_practice-dump.sql` | Копия дампа | Создаётся при запуске |

Логи/дампы/PNG игнорируются Git; в репозитории только `.gitkeep`.

## Чек-лист сдачи

- [ ] MySQL 8.0 поднят с общим `my.cnf`, лог очищен до работы.
- [ ] Загружено 50 пользователей и 500 заказов.
- [ ] Показан `EXPLAIN` JOIN до индекса (`ALL`) и после (`ref` + `idx_user_id`).
- [ ] Продемонстрирован авто-индекс для FK (`orders_fk`, `fk_orders_user`).
- [ ] Сравнены порядок соединения и `STRAIGHT_JOIN`.
- [ ] Создан составной индекс `idx_user_status`.
- [ ] Сравнены `INNER JOIN` и `LEFT JOIN`.
- [ ] Таблица EXPLAIN «до/после» заполнена, скриншоты в `evidence/`.
- [ ] Лог и дамп в `artifacts/`, лог без служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.
