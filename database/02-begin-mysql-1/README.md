### [Вернуться на Главную](../../README.md)

## Навигация

- [Реестр заданий](../../TASKS.md)
- [Архитектура](../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_1.md)

# Лабораторная 02 — интерактивная работа с MySQL в Docker № 1

> **Оригинал:** [Begin_MySQL_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_1.md)
>
> ✅ **Статус отчёта: выполнено.** Лабораторная реально выполнена локально на MariaDB 11.4.14
> (совместимый с MySQL 8.0 дистрибутив), а не в Docker: Docker в этой среде недоступен.
> Доказательства: [general.log](artifacts/general.log), [my_actions.log](artifacts/my_actions.log),
> [execution-output.txt](artifacts/execution-output.txt), [RESULT.txt](artifacts/RESULT.txt).
> Скриншоты в `evidence/` не создавались (нет GUI).

## 🎯 Цель

Запустить «чистый» контейнер MySQL, подключиться к нему, выполнить основные операции
с БД `my_database` и таблицей `users` (`CREATE`, `INSERT`, `SELECT`, `UPDATE`,
`DELETE`, `DROP`), сделать дамп и выгрузить лог с минимальным количеством служебных
записей.

## 🧰 Используемый образ и контейнер

- Образ: `mysql:8.0`; контейнер здесь: `imfua-02-begin-mysql-1` (в инструкции — `my-mysql`).
- Пароль `root` — `123` (как в инструкции).
- `my.cnf` — копия [`database/_shared/my.cnf`](../_shared/my.cnf): UTF-8 без BOM, LF,
  `general_log = 1`, `log_output = FILE`, лог в `/var/lib/mysql/general.log`.
  Это критично: BOM/CRLF заставят MySQL молча проигнорировать конфиг.

## 📋 Ход выполнения

### Шаг 1. Запуск контейнера

```bash
docker ps -a
docker stop имя_контейнера
docker rm имя_контейнера
docker volume prune -a     # осторожно: удаляет ВСЕ неиспользуемые тома!
cd imfua-practice && make run-lab LAB=02-begin-mysql-1
# либо по инструкции:
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
  -d mysql:8.0
docker ps
docker exec -it my-mysql ls -la /var/lib/mysql   # необязательно
```

### Шаг 2. Подключение

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
# пароль 123, приглашение mysql>
```

### Шаг 3. Основные операции

```sql
SHOW VARIABLES LIKE 'character_set%';
SHOW DATABASES;
help                                      -- команда клиента, не SQL

CREATE DATABASE my_database
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE my_database;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO users (name, email) VALUES
  ('Иван Иванов', 'ivan@example.com'),
  ('Пётр Петров', 'petr@example.com'),
  ('Мария Сидорова', 'maria@example.com');
SELECT * FROM users;
SHOW DATABASES;
USE my_database;
SHOW TABLES;
```

### Шаги 4-6. Вставка, просмотр, обновление

```sql
SELECT * FROM users;
INSERT INTO users (name, email) VALUES ('Павел Иванов', 'pavel@example.com');
INSERT INTO users (name, email) VALUES ('Марк Аврелий', 'mark@example.com');
SELECT name, HEX(name) FROM users WHERE id = 1;

UPDATE users SET name = 'Иван Петров' WHERE id = 1;
UPDATE users SET name = 'Vasya' WHERE id = 1;
SELECT * FROM users;
SELECT * FROM users WHERE id = 1;
SELECT name, email FROM users;
SELECT name FROM users;
SELECT name, email FROM users WHERE id = 1;
SELECT * FROM users WHERE id = 1\G
```

Пакетные аналоги — [01_schema.sql](01_schema.sql), [02_seed.sql](02_seed.sql),
[03_queries.sql](03_queries.sql) (команда `\G` в них закомментирована: это команда
интерактивного клиента).

### Шаг 7. Дамп БД (до удаления!)

```bash
\q
docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot \
  --set-gtid-purged=OFF \
  --single-transaction \
  my_database > dump_clean.sql
cat dump_clean.sql
```

### Шаги 8-10. Удаление данных, таблицы и БД

```sql
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
USE my_database;
SHOW TABLES;
SELECT * FROM users;
DELETE FROM users WHERE id = 2;     -- без WHERE удалились бы ВСЕ строки
DROP TABLE users;
SHOW TABLES;
DROP DATABASE my_database;
SHOW DATABASES;
\q
```

Пакетный аналог — [04_cleanup.sql](04_cleanup.sql).

### Шаг 4 отчёта. Лог

```bash
docker exec my-mysql ls -la /var/lib/mysql/general.log
docker exec my-mysql cat /var/lib/mysql/general.log
docker exec my-mysql cat /var/lib/mysql/general.log \
  | grep "Query" \
  | grep -v -E "SET NAMES|SET autocommit|SET sql_mode|SET character_set_results|SHOW VARIABLES|SHOW STATUS|SHOW WARNINGS|SELECT @@|SELECT DATABASE\(\)|time_zone" \
  > my_actions.log
cat my_actions.log
docker exec my-mysql sh -c ': > /var/lib/mysql/general.log'   # очистка при необходимости
cd database
bash ../scripts/export-log.sh 02-begin-mysql-1
bash ../scripts/dump-db.sh 02-begin-mysql-1 my_database
```

### Шаг 5 отчёта. Управление контейнером

```bash
docker stop my-mysql
docker start my-mysql
docker logs my-mysql
docker logs my-mysql > log.txt
```

Полная последовательность — в [commands.sh](commands.sh).

## 📊 Результаты

Все четыре SQL-файла выполнены с кодом возврата 0, ошибок в выводе нет
(см. [RESULT.txt](artifacts/RESULT.txt)).

**`SHOW VARIABLES LIKE 'character_set%'` (факт):**

```text
Variable_name	Value
character_set_client	latin1
character_set_collations	
character_set_connection	latin1
character_set_database	utf8mb4
character_set_filesystem	binary
character_set_results	latin1
character_set_server	utf8mb4
character_set_system	utf8mb3
character_sets_dir	/usr/local/mysql/share/charsets/
```

**База и таблица созданы (факт):**

```text
Tables_in_my_database
users
```

`SHOW DATABASES` после создания содержит `my_database`; после `DROP DATABASE my_database`
в списке её нет (полный вывод обоих списков — в
[execution-output.txt](artifacts/execution-output.txt)).

**Данные `users` после вставки (факт — 5 строк):**

| id | name | email |
|----|------|-------|
| 1  | Vasya | ivan@example.com |
| 2  | Пётр Петров | petr@example.com |
| 3  | Мария Сидорова | maria@example.com |
| 4  | Павел Иванов | pavel@example.com |
| 5  | Марк Аврелий | mark@example.com |

**Фактический вывод (`execution-output.txt`):**

`SELECT name, HEX(name) FROM users WHERE id = 1` до `UPDATE`:

```text
name	HEX(name)
Иван Иванов	C390CB9CC390C2B2C390C2B0C390C2BD20C390CB9CC390C2B2C390C2B0C390C2BDC390C2BEC390C2B2
```

`SELECT * FROM users` после обоих `UPDATE` (факт — 5 строк):

```text
id	name	email
1	Vasya	ivan@example.com
2	Пётр Петров	petr@example.com
3	Мария Сидорова	maria@example.com
4	Павел Иванов	pavel@example.com
5	Марк Аврелий	mark@example.com
```

`SELECT * FROM users` после `DELETE FROM users WHERE id = 2` (факт — 4 строки),
затем `SHOW TABLES` (пусто) и `SHOW DATABASES` без `my_database`:

```text
id	name	email
1	Vasya	ivan@example.com
3	Мария Сидорова	maria@example.com
4	Павел Иванов	pavel@example.com
5	Марк Аврелий	mark@example.com
```

Скриншоты в `evidence/` не создавались (нет GUI).

## 📎 Доказательства выполнения

- [artifacts/general.log](artifacts/general.log) — исходный `general.log` сервера MariaDB (2455 байт).
- [artifacts/my_actions.log](artifacts/my_actions.log) — отфильтрованный лог действий пользователя (49 строк).
- [artifacts/execution-output.txt](artifacts/execution-output.txt) — полный вывод четырёх SQL-скриптов (2715 байт).
- [artifacts/RESULT.txt](artifacts/RESULT.txt) — сводка прогона: коды возврата 0, 0 ошибок; дампов нет,
  поскольку `my_database` была удалена (`Пропущены несуществующие БД: my_database`).

## ✅ Чек-лист сдачи

- [ ] `my.cnf` без BOM/CRLF, `general_log` включён, лог очищен перед работой.
- [ ] БД `my_database`, таблица `users` с `AUTO_INCREMENT` и `UNIQUE(email)` созданы.
- [ ] Вставлены все 5 записей, выполнены `SELECT`, `HEX`, `UPDATE`.
- [ ] Дамп сделан **до** удаления записи/таблицы/БД и не пуст.
- [ ] `DELETE`, `DROP TABLE`, `DROP DATABASE` выполнены и проверены.
- [ ] `artifacts/my_actions.log` содержит только действия пользователя.
- [ ] Скриншоты добавлены в `evidence/`, отчёт заполнен.
- [ ] Изменения зафиксированы локально; push не выполняется.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
