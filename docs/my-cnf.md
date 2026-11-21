### [Вернуться на Главную](../README.md)

## Навигация

- [Реестр заданий](../TASKS.md)
- [Архитектура](../ARCHITECTURE.md)

# Почему `my.cnf` должен быть в UTF-8 без BOM и с LF

(см. предупреждения в инструкциях: [Begin_MySQL_1](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_1.md), [FULLTEXT](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/FULLTEXT.md))

MySQL **молча игнорирует** конфигурационный файл, если он сохранён с BOM (`EF BB BF`)
или с переводами строк CRLF (`0D 0A`). Признак проблемы: `general_log` не включается,
файл `/var/lib/mysql/general.log` не создаётся.

Правильный способ создать файл — heredoc в WSL/Linux:

```bash
cat > my.cnf <<'EOF'
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
general_log = 1
general_log_file = /var/lib/mysql/general.log
log_output = FILE

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
EOF
```

Проверка на хосте:

```bash
head -c 3 my.cnf | od -An -tx1   # не должно быть ef bb bf
grep -q $'\r' my.cnf && echo CRLF || echo LF
```

В этом репозитории эталонный файл лежит в `database/_shared/my.cnf`, а
`scripts/check.sh` проверяет все текстовые файлы на BOM/CRLF.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
