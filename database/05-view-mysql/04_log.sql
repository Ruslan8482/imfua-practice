-- ============================================================
-- Лабораторная 05, раздел 14: проверка файлового лога.
-- Вывод лога и его фильтрация выполняются командами хоста
-- (см. commands.sh и README.md).
-- ============================================================

-- my.cnf уже содержит general_log = 1 и log_output = FILE,
-- поэтому после перезапуска контейнера лог должен быть активен:
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'log_output';

-- Если лог выключен, включить вручную:
-- SET GLOBAL general_log = 'ON';
-- SET GLOBAL log_output = 'FILE';

-- Лог лежит в /var/lib/mysql/general.log внутри контейнера.
-- Команды хоста (Git-Bash):
-- docker exec my-mysql ls -la /var/lib/mysql/general.log
-- docker exec my-mysql cat /var/lib/mysql/general.log
-- docker cp my-mysql:/var/lib/mysql/general.log ./general.log
-- docker exec my-mysql cat /var/lib/mysql/general.log \
--   | grep "Query" \
--   | grep -v -E "SET NAMES|SET autocommit|SET sql_mode|SET character_set_results|SHOW VARIABLES|SHOW STATUS|SHOW WARNINGS|SELECT @@|SELECT DATABASE\(\)|time_zone" \
--   > my_actions.log
-- docker exec my-mysql sh -c ': > /var/lib/mysql/general.log'
