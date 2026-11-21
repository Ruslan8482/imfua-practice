### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/ORDER_BY_GROUP_BY.md)

# Лабораторная 14 — ускорение ORDER BY / GROUP BY

**Оригинал:** [ORDER_BY_GROUP_BY.md — Ускорение сортировки и группировки в MySQL](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/ORDER_BY_GROUP_BY.md)  
Локальная копия инструкции (только для чтения): `/tmp/opencode/imfua-src/content/Courses/Basics_database_design/content/bd/ORDER_BY_GROUP_BY.md`

> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt)
> и дампы в `artifacts/`. Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

Понять, когда возникают `Using filesort` и `Using temporary`, и научиться
проектировать индексы под `ORDER BY` / `GROUP BY`: индекс по столбцу сортировки,
однородная и разнонаправленная сортировка, нисходящий индекс MySQL 8.0+,
`Loose Index Scan`, `Tight Index Scan` и покрывающий индекс для группировки.

## 🧰 Состав каталога

| Файл | Что делает |
|------|------------|
| `my.cnf` | Копия `database/_shared/my.cnf` (UTF-8 без BOM, LF, general_log) |
| `01_schema.sql` | `CREATE DATABASE sort_practice`, таблица `orders` с `INDEX idx_customer` |
| `02_seed.sql` | 500 строк через `INSERT ... SELECT` (10 × 10 × 5), `SELECT COUNT(*)` |
| `03_queries.sql` | Эксперименты 1–7 строго по порядку |
| `commands.sh` | `docker run`, очистка лога, запуск SQL, экспорт лога, дамп |
| `artifacts/.gitkeep`, `evidence/.gitkeep` | Каталоги для артефактов и скриншотов |

## 📋 Пошаговое выполнение

```bash
cd imfua-practice
make check
bash database/14-order-by-group-by/commands.sh    # контейнер imfua-14-order-by-group-by
```

Шаги `commands.sh`:

1. Удаляет старый контейнер/volume; **не** выполняет `docker volume prune -a`.
2. Копирует общий `my.cnf` в каталог задания.
3. `docker run --name imfua-14-order-by-group-by -e MYSQL_ROOT_PASSWORD=123 \
   -e LANG=C.UTF-8 -e MYSQL_INITDB_SKIP_TZINFO=1 -v <volume>:/var/lib/mysql \
   -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro -d mysql:8.0`.
4. Проверяет `general_log` / `log_output`; ждёт готовности сервера.
5. Очищает лог: `docker exec -u mysql imfua-14-order-by-group-by sh -c ': > /var/lib/mysql/general.log'`.
6. Выполняет `01_schema.sql` → `02_seed.sql` → `03_queries.sql`.
7. `bash scripts/export-log.sh 14-order-by-group-by` и `bash scripts/dump-db.sh 14-order-by-group-by sort_practice`.

Интерактивно: `docker exec -it imfua-14-order-by-group-by mysql --default-character-set=utf8mb4 -uroot -p` (пароль `123`).

## 📊 Результаты: EXPLAIN «до/после»

**СУБД:** MariaDB 11.4.14 (`Version: 11.4.14-MariaDB-log` — первая строка
`artifacts/general.log` и `artifacts/my_actions.log`). Все значения ниже взяты из
10 таблиц `EXPLAIN` в `artifacts/execution-output.txt` (блок `03_queries.sql`).

| № / эксперимент | Запрос | До: `type / key / rows / Extra` | После: `type / key / rows / Extra` |
|-----------------|--------|----------------------------------|-------------------------------------|
| 1. ORDER BY без индекса | `EXPLAIN SELECT * FROM orders ORDER BY amount DESC;` | `ALL` / `NULL` / `500` / `Using filesort` | — |
| 2. `CREATE INDEX idx_amount` | тот же `EXPLAIN` | `ALL` / `NULL` / `500` / `Using filesort` | `ALL` / `NULL` / `500` / `Using filesort` (MariaDB не выбрала `idx_amount`, `filesort` остался) |
| 3. `ORDER BY amount ASC` | `EXPLAIN SELECT * FROM orders ORDER BY amount ASC;` | не выведено | `ALL` / `NULL` / `500` / `Using filesort` (backward scan не проявился) |
| 3. Два столбца, одинаковое направление | `... ORDER BY status ASC, amount ASC;` | не выведено | `ALL` / `NULL` / `500` / `Using filesort` |
| 3. Разное направление | `... ORDER BY status ASC, amount DESC;` | `ALL` / `NULL` / `500` / `Using filesort` | `ALL` / `NULL` / `500` / `Using filesort` (после `idx_status_amount_desc` план не изменился) |
| 4. GROUP BY без индекса | `EXPLAIN SELECT status, COUNT(*) FROM orders GROUP BY status;` | `index` / `idx_status_amount` / `500` / `Using index` — «чистого» плана без индекса в выводе нет: к этому моменту уже созданы индексы экспериментов 2–3 | — |
| 5. `CREATE INDEX idx_status` | тот же `EXPLAIN` | `index` / `idx_status_amount` / `500` / `Using index` | `index` / `idx_status_amount` / `500` / `Using index` (оптимизатор выбрал `idx_status_amount`, не `idx_status`) |
| 6. `Tight Index Scan` | `EXPLAIN SELECT status, SUM(amount) FROM orders GROUP BY status;` | `index` / `idx_status_amount` / `500` / `Using index` | `index` / `idx_status_amount` / `500` / `Using index` (без `Using temporary`) |
| 7. Покрывающий индекс | `CREATE INDEX idx_status_amount_cover` + тот же `EXPLAIN` | `index` / `idx_status_amount` / `500` / `Using index` | `index` / `idx_status_amount` / `500` / `Using index` (`idx_status_amount_cover` в плане не выбран) |

Проверка данных: `SELECT COUNT(*) FROM orders;` → `500`; `SELECT status, COUNT(*) ...` →
не выведено (в `artifacts/execution-output.txt` нет вывода группировки).

> Ожидаемые эффекты из инструкции (`index` + без `filesort` для ORDER BY, `idx_status` для
> GROUP BY) на MariaDB 11.4.14 не воспроизвелись: фактические планы приведены выше.
> `Using temporary` в выведенных планах отсутствует; для GROUP BY выбран `idx_status_amount`
> с `Using index`.

## 📸 Места под скриншоты (не создавались — нет GUI)

Файлы `evidence/*.png` не создавались; таблица ниже сохраняет места, где они
предусмотрены инструкцией.

| Файл | Что фотографируем |
|------|--------------------|
| `evidence/01-count.png` | `SELECT COUNT(*) FROM orders;` = 500 |
| `evidence/02-order-by-before.png` | `EXPLAIN ... ORDER BY amount DESC` до индекса (`Using filesort`) |
| `evidence/03-order-by-after.png` | Тот же `EXPLAIN` после `idx_amount` |
| `evidence/04-mixed-direction.png` | `ORDER BY status ASC, amount DESC` до/после `idx_status_amount_desc` |
| `evidence/05-group-by-before.png` | `EXPLAIN ... GROUP BY status` с `Using temporary; Using filesort` |
| `evidence/06-loose-scan.png` | Тот же `EXPLAIN` после `idx_status` |
| `evidence/07-covering.png` | `EXPLAIN SELECT status, SUM(amount) ...` с `Using index` |
| `evidence/08-log-dump.png` | `head artifacts/my_actions.log`, `head artifacts/sort_practice-dump.sql` |

## 📎 Артефакты

Цепочка: `/var/lib/mysql/general.log` (контейнер) → `artifacts/general.log`
→ `artifacts/my_actions.log` (только ваши действия) → отчёт.

| Путь | Содержимое | Статус |
|------|------------|--------|
| `artifacts/general.log` | Полный general.log | Создан |
| `artifacts/my_actions.log` | Отфильтрованный лог | Создан |
| `artifacts/execution-output.txt` | Вывод SQL, включая все таблицы `EXPLAIN` | Создан |
| `artifacts/RESULT.txt` | Сводка: коды возврата 0, ошибок 0 | Создан |
| `artifacts/sort_practice-dump.sql` | Дамп 500 строк и всех индексов экспериментов | Создан |
| `database/logs/14-order-by-group-by-actions.log` | Копия лога | Не создавалась (каталога `database/logs` нет) |
| `database/dumps/14-order-by-group-by-sort_practice-dump.sql` | Копия дампа | Не создавалась (каталога `database/dumps` нет) |

Логи и дамп в `artifacts/` созданы при локальном запуске; PNG в `evidence/` не создавались.

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — полный general.log; первая строка фиксирует
  `Version: 11.4.14-MariaDB-log` (MariaDB 11.4.14).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованные действия пользователя
  (49 строк по `RESULT.txt`).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — реальный вывод SQL со всеми
  10 планами `EXPLAIN` и `COUNT(*) = 500`.
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — 3 SQL-файла, коды возврата 0, ошибок 0.
- [artifacts/sort_practice-dump.sql](artifacts/sort_practice-dump.sql) — дамп базы `sort_practice`
  (21546 байт).
- `artifacts/.gitkeep` — служебный файл каталога.

> Ниже — исходные критерии сдачи. Пункты про Docker/WSL и скриншоты не применимы:
> лабораторная выполнялась локально на MariaDB 11.4.14, GUI отсутствует.

## ✅ Чек-лист сдачи

- [ ] MySQL 8.0 поднят с общим `my.cnf`, лог очищен до работы.
- [ ] Загружено ровно 500 строк (`SELECT COUNT(*)`).
- [ ] Эксперименты 1–7 выполнены в порядке файла `03_queries.sql`.
- [ ] Показано исчезновение `Using filesort` после `idx_amount`.
- [ ] Показано исчезновение `Using temporary` после `idx_status`.
- [ ] Показана разница однородной и разнонаправленной сортировки + нисходящий индекс.
- [ ] Получен `Using index` для покрывающего индекса.
- [ ] Таблица EXPLAIN «до/после» заполнена, скриншоты в `evidence/`.
- [ ] Лог и дамп в `artifacts/`; `my_actions.log` без служебных записей.
- [ ] Ссылка на отчёт отправлена преподавателю; `push` не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
