### [Вернуться на Главную](../README.md)

## Навигация

- [Реестр заданий](../TASKS.md)
- [Архитектура](../ARCHITECTURE.md)

# Лабораторные по основам проектирования баз данных

16 лабораторных из [курса](https://github.com/rurewa/imfua/tree/main/content/Courses/Basics_database_design).

## 🧰 Каталог

| № | Задание | Что делаем |
|---|---------|------------|
| 01 | `01-lesson-1` | 4 нормализованные таблицы: customers, products, reports, report_items |
| 02 | `02-begin-mysql-1` | первый запуск MySQL в Docker, создание БД/таблиц, лог |
| 03 | `03-begin-mysql-2` | SELECT/IN/агрегаты/JOIN/подзапросы/UPDATE/DELETE/ALTER, дамп и восстановление |
| 04 | `04-products` | операции над products 1 / products 2 (EXCEPT, INTERSECT) |
| 05 | `05-view-mysql` | представления, фильтрация лога через VIEW |
| 06 | `06-normalization-1` | нормализация sales_unnormalized_2 → 3NF |
| 07 | `07-normalization-2` | нормализация sales_unnormalized → 3NF |
| 08 | `08-normalization-3` | лабораторная № 3 по нормализации |
| 09 | `09-normalization-4` | лабораторная № 4 по нормализации |
| 10 | `10-normalization-5` | лабораторная № 5 по нормализации |
| 11 | `11-aliases` | алиасы в SELECT/FROM/JOIN/подзапросах |
| 12 | `12-index` | EXPLAIN до/после индекса, составные и покрывающие индексы |
| 13 | `13-fulltext` | FULLTEXT: natural language, boolean, query expansion |
| 14 | `14-order-by-group-by` | устранение Using filesort / Using temporary |
| 15 | `15-index-join` | индексы для JOIN, порядок соединения |
| 16 | `16-normalization-common` | аномалии → 3NF, проверка переноса данных |

## ✅ Статус

Все 16 лабораторных **реально выполнены** локальным MariaDB 11.4.14.
В каждом `NN-*/artifacts/` — настоящие `general.log`, `my_actions.log`,
`execution-output.txt`, `RESULT.txt` и дампы; отчёты заполнены фактическими результатами.

## 🧰 Запуск

Вариант без Docker (тот, что использовался здесь):

```bash
bash scripts/start-local-mariadb.sh
bash scripts/collect-evidence.sh
```

Вариант с Docker (по оригинальной инструкции):

```bash
make run-lab LAB=01-lesson-1
docker exec -it imfua-01-lesson-1 mysql -uroot -proot
# выполняем 01_schema.sql, 02_seed.sql, 03_queries.sql
bash scripts/export-log.sh 01-lesson-1
bash scripts/dump-db.sh 01-lesson-1 <имя_базы>
```

Общий конфиг `database/_shared/my.cnf` обеспечивает UTF-8 и `general_log`.
Подробнее — [docs/workflow.md](../docs/workflow.md) и [docs/my-cnf.md](../docs/my-cnf.md).

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
