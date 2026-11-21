### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index_JOIN.md)

# Лабораторная 15 — индексы и JOIN

**Оригинал:** [Index_JOIN.md — Индексы и `JOIN`: оптимизация соединений в MySQL](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index_JOIN.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/Index_JOIN.md`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

> ℹ️ **Адаптация синтаксиса под MariaDB.** В `03_queries.sql` вместо `EXPLAIN FORMAT=TREE`
> (MySQL 8.0.16+) использован `EXPLAIN FORMAT=JSON`: `FORMAT=TREE` в MariaDB 11.4 недоступен.
> Вывод JSON с полями `query_block`, `nested_loop`, `access_type`, `loops` лежит в
> `artifacts/execution-output.txt`.

## 🎯 Цель

Показать, почему `JOIN` без индекса на столбце соединения даёт `type: ALL` и полный
перебор; создать `idx_user_id` и получить `ref`; разобрать автоматическое создание
индекса для `FOREIGN KEY`, порядок соединения (driving table), составной индекс
`(join_col, filter_col)` и разницу `INNER JOIN` / `LEFT JOIN`.

## 🧰 Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, general_log) |
| `01_schema.sql` | `CREATE DATABASE join_practice`, таблицы `users` и `orders` **без FK и без индекса** на `user_id` |
| `02_seed.sql` | 50 пользователей + 500 заказов через `INSERT ... SELECT`, проверки `COUNT(*)` |
| `03_queries.sql` | Эксперименты 1–2, порядок соединения, составной индекс, INNER/LEFT, `EXPLAIN FORMAT=TREE` |
| `04_fk_demo.sql` | Отдельная таблица `orders_fk` с `CONSTRAINT fk_orders_user` — авто-индекс InnoDB |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, `export-log.sh`, `dump-db.sh` |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## 📋 Пошаговое выполнение

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

## 📊 Результаты: EXPLAIN «до/после»

**СУБД:** MariaDB 11.4.14 (`Version: 11.4.14-MariaDB-log` — первая строка
`artifacts/general.log` и `artifacts/my_actions.log`). Все значения ниже взяты из
табличных строк `EXPLAIN` в `artifacts/execution-output.txt` (блоки `03_queries.sql`
и `04_fk_demo.sql`).

| № / эксперимент | Запрос | До: `table / type / key / rows / Extra` | После: `table / type / key / rows / Extra` |
|-----------------|--------|------------------------------------------|---------------------------------------------|
| 1. Без индекса | `EXPLAIN SELECT o.id, o.amount, u.name FROM orders o JOIN users u ON o.user_id = u.id WHERE u.vip_level = 3;` | `o: ALL / NULL / 500 / Extra пустое; u: eq_ref / PRIMARY / 1 / Using where` (driving — `o`) | — |
| 2. `CREATE INDEX idx_user_id ON orders(user_id);` | тот же `EXPLAIN` | см. строку 1 | `o: ALL / NULL (possible_keys = idx_user_id) / 500 / Extra пустое; u: eq_ref / PRIMARY / 1 / Using where` — ожидаемый `ref / idx_user_id` не получен |
| 3. Порядок соединения | тот же `EXPLAIN`, первая строка | `o` — driving table | `o`; с `STRAIGHT_JOIN`: `o` (план не изменился) |
| 4. Составной индекс | `... WHERE u.vip_level = 3 AND o.status = 'paid';` | не выведено (`EXPLAIN` с фильтром по `o.status` выполнялся только после создания индекса) | `u: ALL / NULL / 50 / Using where; o: ref / idx_user_status / 3 / Using index condition` (ref = `join_practice.u.id,const`) |
| 5. INNER JOIN | `EXPLAIN SELECT ... INNER JOIN users u ... WHERE u.vip_level = 3;` | `o → u` (порядок строк плана) | `o: ALL / NULL (possible_keys = idx_user_id,idx_user_status) / 500 / Extra пустое; u: eq_ref / PRIMARY / 1 / Using where` |
| 5. LEFT JOIN | `EXPLAIN SELECT ... LEFT JOIN users u ... WHERE u.vip_level = 3;` | не выведено | `o: ALL / NULL / 500 / Extra пустое; u: eq_ref / PRIMARY / 1 / Using where` — план совпадает с INNER JOIN |
| 5. LEFT JOIN без WHERE | `EXPLAIN SELECT ... LEFT JOIN users u ON o.user_id = u.id;` | не выведено | `o: ALL / NULL / 500 / Extra пустое; u: eq_ref / PRIMARY / 1 / Extra пустое` |
| FK (04_fk_demo) | `SHOW INDEX FROM orders_fk` + `EXPLAIN SELECT ... FROM orders_fk f JOIN users u ...` | — | `Key_name = fk_orders_user` (`user_id`, BTREE); `u: ALL / NULL / 50 / Using where; f: ref / fk_orders_user / 1 / Extra пустое` |

Проверка объёмов: `SELECT COUNT(*) FROM users;` → `50`, `SELECT COUNT(*) FROM orders;` → `500`,
`SELECT COUNT(*) FROM orders_fk;` → `500`.

> План `EXPLAIN FORMAT=JSON` (адаптация вместо `FORMAT=TREE`) из вывода: `cost = 0.5421036`;
> первая таблица `o` — `access_type: ALL`, `rows: 500`, `loops: 1`; вторая `u` —
> `access_type: eq_ref`, `key: PRIMARY`, `rows: 1`, `loops: 500`,
> `attached_condition: u.vip_level = 3`. Фактический план отличается от ожидавшегося
> в инструкции (`ref / idx_user_id`): MariaDB выбрала `o` как driving table и не применила
> `idx_user_id` для соединения; `Using join buffer` в выводе отсутствует.

## 📸 Места под скриншоты (не создавались — нет GUI)

Файлы `evidence/*.png` не создавались; таблица ниже сохраняет места, где они
предусмотрены инструкцией.

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

## 📎 Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только ваши SQL-действия).

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создан |
| `artifacts/my_actions.log` | Отфильтрованный лог | Создан |
| `artifacts/execution-output.txt` | Вывод SQL, включая таблицы `EXPLAIN` и JSON-план | Создан |
| `artifacts/RESULT.txt` | Сводка: коды возврата 0, ошибок 0 | Создан |
| `artifacts/join_practice-dump.sql` | Дамп `users`, `orders`, `orders_fk`, индексы `idx_user_id`, `idx_user_status` | Создан |
| `database/logs/15-index-join-actions.log` | Копия лога | Не создавалась (каталога `database/logs` нет) |
| `database/dumps/15-index-join-join_practice-dump.sql` | Копия дампа | Не создавалась (каталога `database/dumps` нет) |

Логи и дамп в `artifacts/` созданы при локальном запуске; PNG в `evidence/` не создавались.

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general.log; первая строка фиксирует
  `Version: 11.4.14-MariaDB-log` (MariaDB 11.4.14).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованные действия пользователя
  (122 строки по `RESULT.txt`).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод SQL: планы
  `EXPLAIN` до/после индексов, `SHOW INDEX FROM orders_fk` и `EXPLAIN FORMAT=JSON`.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — 4 SQL-файла, коды возврата 0, ошибок 0.
- [artifacts/join_practice-dump.sql](artifacts/join_practice-dump.sql) — дамп базы
  `join_practice` (43968 байт).
- `artifacts/.gitkeep` — служебный файл каталога.

> Ниже — исходные критерии сдачи. Пункты про Docker/WSL и скриншоты не применимы:
> лабораторная выполнялась локально на MariaDB 11.4.14, GUI отсутствует.

## ✅ Чек-лист сдачи

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

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
