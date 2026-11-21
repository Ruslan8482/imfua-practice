#!/usr/bin/env bash
# collect-evidence.sh — собрать доказательства выполнения лабораторных по SQL.
#
# Для каждой лабораторной database/NN-*:
#   1) берёт SQL-файлы в порядке сортировки по имени;
#   2) очищает general_log (OFF -> truncate -> ON);
#   3) выполняет SQL через mariadb --force, пишет stdout+stderr с разделителями;
#   4) копирует general.log и делает my_actions.log без служебных строк;
#   5) дампит найденные БД (CREATE DATABASE / USE / env LAB_DBS);
#   6) пишет короткий artifacts/RESULT.txt;
#   7) продолжает при ошибках и в конце печатает сводную таблицу.
#
# Переопределение путей через окружение:
#   MARIADB_BIN   каталог бинарников (по умолчанию /tmp/opencode/mariadb/bin;
#                 можно передать и путь к самому mariadb — тогда берём его каталог)
#   SOCKET        UNIX-сокет (по умолчанию /tmp/opencode/mariadb/run/mysqld.sock)
#   GENERAL_LOG   файл general.log (по умолчанию /tmp/opencode/mariadb/data/general.log)
#   REPO_ROOT     корень репозитория (по умолчанию каталог выше каталога скрипта)
#   LAB_DBS       дополнительный список БД через запятую/пробелы (объединяется с
#                 БД, найденными в SQL)
#
# Намеренно НЕ используется set -e: внутренние сбои должны фиксироваться как
# доказательство, а не прерывать обход остальных лабораторных.
set -o pipefail
export LC_ALL=C

# ---------------------------------------------------------------------------
# Вспомогательные функции
# ---------------------------------------------------------------------------
die()   { printf 'ОШИБКА: %s\n' "$*" >&2; exit 2; }
warn()  { printf 'ВНИМАНИЕ: %s\n' "$*" >&2; }
check_executable() {
  [ -x "$1" ] || die "не найден исполняемый файл $2: $1 (установите MARIADB_BIN=/path/to/bin)"
}
human_bytes() {
  awk -v b="${1:-0}" 'BEGIN {
    if (b >= 1048576) printf "%.1f MiB", b/1048576;
    else if (b >= 1024) printf "%.1f KiB", b/1024;
    else printf "%d B", b
  }'
}
join_by() {
  local sep="$1"; shift
  local out="" item
  for item in "$@"; do
    if [ -n "$out" ]; then out+="$sep"; fi
    out+="$item"
  done
  printf '%s' "$out"
}

# Список БД лабораторной нужен ДО выполнения: перед DROP DATABASE делаем
# дамп до удаления, а после CREATE DATABASE в restore-скрипте импортируем его обратно.
db_list_for_lab() {
  db_list=()
  while IFS= read -r db; do
    [ -n "$db" ] || continue
    case "${db,,}" in
      mysql|information_schema|performance_schema|sys|'') continue ;;
    esac
    db_list+=("$db")
  done < <(
    {
      if [ -n "${LAB_DBS:-}" ]; then printf '%s\n' "${LAB_DBS//,/ }"; fi
      if [ "${#sql_files[@]}" -gt 0 ]; then
        awk '
          function emit(token,   n, a, i, name) {
            n = split(token, a, /[[:space:]`"]+/); name = ""
            for (i = 1; i <= n; i++) if (a[i] != "") name = a[i]
            if (name != "" && name != "if" && name != "not" && name != "exists") print name
          }
          {
            line = $0; sub(/--.*/, "", line); sub(/#.*/, "", line)
            sub(/^[[:space:]]+/, "", line); low = tolower(line)
            if (match(low, /^create[[:space:]]+(database|schema)[[:space:]]+(if[[:space:]]+not[[:space:]]+exists[[:space:]]+)?[a-z0-9_`$"]+/))
              emit(substr(line, RSTART, RLENGTH))
            if (match(low, /^use[[:space:]]+[a-z0-9_`$"]+/)) emit(substr(line, RSTART, RLENGTH))
          }
        ' "${sql_files[@]}"
      fi
    } | awk 'NF && !seen[$0]++'
  )
}

# ---------------------------------------------------------------------------
# Настройки и проверка окружения (ничего не запускаем, только проверяем пути)
# ---------------------------------------------------------------------------
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
REPO_ROOT="${REPO_ROOT:-$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)}"
DB_ROOT="$REPO_ROOT/database"

MARIADB_BIN="${MARIADB_BIN:-/tmp/opencode/mariadb/bin}"
# Мягко поддерживаем и случай, когда передали путь к самому бинарнику.
if [ -f "$MARIADB_BIN" ]; then MARIADB_BIN=$(dirname -- "$MARIADB_BIN"); fi
MARIADB="$MARIADB_BIN/mariadb"
MYSQLDUMP="$MARIADB_BIN/mariadb-dump"
[ -x "$MYSQLDUMP" ] || MYSQLDUMP="$MARIADB_BIN/mysqldump"

SOCKET="${SOCKET:-/tmp/opencode/mariadb/run/mysqld.sock}"
GENERAL_LOG="${GENERAL_LOG:-/tmp/opencode/mariadb/data/general.log}"

printf 'Проверка окружения:\n'
printf '  REPO_ROOT  = %s\n' "$REPO_ROOT"
printf '  MARIADB_BIN= %s\n' "$MARIADB_BIN"
printf '  SOCKET     = %s\n' "$SOCKET"
printf '  GENERAL_LOG= %s\n' "$GENERAL_LOG"

# Для этой задачи обязательны клиент и mysqldump; серверные утилиты проверяем,
# но их отсутствие не мешает сборке доказательств (сервер уже запущен).
check_executable "$MARIADB"   mariadb
check_executable "$MYSQLDUMP" mysqldump
for helper in mariadbd mariadb-install-db; do
  if [ -x "$MARIADB_BIN/$helper" ]; then
    printf '  найден: %s\n' "$MARIADB_BIN/$helper"
  else
    warn "не найден $helper в $MARIADB_BIN (для сбора доказательств не используется)"
  fi
done

[ -d "$DB_ROOT" ] || die "каталог лабораторных не найден: $DB_ROOT (проверьте REPO_ROOT)"
if [ -S "$SOCKET" ]; then
  printf '  сокет найден\n'
else
  die "UNIX-сокет MariaDB не найден: $SOCKET (запустите сервер или задайте SOCKET=...)"
fi
LOG_DIR=$(dirname -- "$GENERAL_LOG")
[ -d "$LOG_DIR" ] || die "каталог general_log не найден: $LOG_DIR (проверьте GENERAL_LOG)"
if [ ! -e "$GENERAL_LOG" ]; then
  warn "general_log ещё не существует: $GENERAL_LOG (будет создан при очистке)"
fi

# Регулярные выражения для фильтрации лога и поиска ошибок.
FILTER_RE='Connect|Quit|SET NAMES|SHOW VARIABLES|SET timestamp|INSERT INTO (`?help_topic`?|`?time_zone`?)|administrator command'
ERR_RE='ERROR [0-9]{4}|Access denied|Unknown database|doesn.t exist|Duplicate entry|Cannot add foreign key|check option failed|failed with error'
# Фатальными считаем только ошибки подключения/доступа/потери сервера:
# ожидаемые ошибки SQL (дубликаты, нарушения ограничений и т.п.) не фатальны.
FATAL_RE="can.t connect|cannot connect|access denied|lost connection|server has gone away|unknown database|permission denied|ERROR 10(45|49)|ERROR 20(02|03|06)"

# ---------------------------------------------------------------------------
# Список лабораторных
# ---------------------------------------------------------------------------
lab_dirs=()
while IFS= read -r -d '' d; do lab_dirs+=("$d"); done < <(
  find "$DB_ROOT" -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9]-*' -print0 | sort -z
)
if [ "${#lab_dirs[@]}" -eq 0 ]; then
  die "в $DB_ROOT не найдено лабораторных вида NN-*"
fi
printf 'Найдено лабораторных: %d\n\n' "${#lab_dirs[@]}"

# Массивы для итоговой сводной таблицы.
sum_lab=(); sum_sql=(); sum_act=(); sum_dump=(); sum_size=(); sum_status=()
ok_labs=0

# ---------------------------------------------------------------------------
# Основной цикл
# ---------------------------------------------------------------------------
for labdir in "${lab_dirs[@]}"; do
  lab=$(basename -- "$labdir")
  art="$labdir/artifacts"
  out="$art/execution-output.txt"
  gen_copy="$art/general.log"
  actions="$art/my_actions.log"
  result="$art/RESULT.txt"
  mkdir -p -- "$art"

  printf '[%s] старт\n' "$lab"
  fatal_reasons=()
  executed=(); file_rcs=(); executed_list=""
  dump_names=(); dump_sizes=(); skipped_dbs=()
  overall_rc=0

  # 1. SQL-файлы строго по имени (LC_ALL=C задан выше; -print0/-z защищают
  #    имена с пробелами и переводом строки).
  sql_files=()
  while IFS= read -r -d '' f; do sql_files+=("$f"); done < <(
    find "$labdir" -maxdepth 1 -type f -name '*.sql' -print0 | sort -z
  )
  if [ "${#sql_files[@]}" -eq 0 ]; then
    warn "$lab: SQL-файлы не найдены"
    fatal_reasons+=("нет SQL-файлов")
  fi
  db_list_for_lab

  # 2. Безопасная очистка general_log: выключить -> обнулить -> включить.
  clear_err=$("$MARIADB" --default-character-set=utf8mb4 --socket="$SOCKET" -uroot -e 'SET GLOBAL general_log=OFF; TRUNCATE TABLE mysql.general_log;' 2>&1)
  if [ $? -ne 0 ]; then
    warn "$lab: не удалось выключить general_log: $clear_err"
    fatal_reasons+=("не удалось выключить general_log")
  fi
  if ! : > "$GENERAL_LOG" 2>/dev/null; then
    warn "$lab: не удалось очистить $GENERAL_LOG"
    fatal_reasons+=("не удалось очистить general_log")
  fi
  clear_err=$("$MARIADB" --default-character-set=utf8mb4 --socket="$SOCKET" -uroot -e 'SET GLOBAL general_log=ON;' 2>&1)
  if [ $? -ne 0 ]; then
    warn "$lab: не удалось включить general_log: $clear_err"
    fatal_reasons+=("не удалось включить general_log")
  fi

  # 3. Выполнение SQL.
  #
  # Почему --force: в учебных SQL намеренно встречаются ожидаемые ошибки
  # (повторный CREATE DATABASE, дубликаты ключей, нарушения FOREIGN KEY и т.п.).
  # В пакетном режиме без --force клиент остановится после первой же ошибки,
  # и остальные файлы лабораторной не выполняются — доказательства были бы
  # неполными.
  # С --force клиент продолжает, а каждая ошибка остаётся в execution-output.txt
  # и попадает в список ошибок RESULT.txt. Код возврата каждого файла метим явно.
  : > "$out"
  for sql in "${sql_files[@]}"; do
    base=$(basename -- "$sql")

    # Лабораторные 03 и 04 удаляют БД, затем создают её заново и проверяют
    # восстановление. Сохраняем дамп до DROP и импортируем его после CREATE,
    # иначе шаги verify работают с пустой базой.
    case "$base" in
      09_drop.sql|04_drop.sql)
        for db in "${db_list[@]}"; do
          exists=$("$MARIADB" --default-character-set=utf8mb4 --socket="$SOCKET" -uroot -N -B \
            -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$db'" 2>/dev/null)
          if [ "$exists" = "1" ]; then
            "$MYSQLDUMP" --socket="$SOCKET" -uroot --single-transaction --skip-set-charset \
              "$db" > "$art/${db}-pre-drop-dump.sql" 2>> "$out" || :
          fi
        done
        ;;
    esac

    {
      printf '===== BEGIN %s =====\n' "$base"
      "$MARIADB" --default-character-set=utf8mb4 --force --socket="$SOCKET" -uroot < "$sql" 2>&1
      rc=$?
      printf '===== END %s : exit=%d =====\n' "$base" "$rc"
    } >> "$out"
    executed+=("$base")
    file_rcs+=("$rc")
    if [ "$rc" -ne 0 ] && [ "$overall_rc" -eq 0 ]; then overall_rc="$rc"; fi

    # Импорт делаем ПОСЛЕ CREATE DATABASE в restore-скрипте.
    case "$base" in
      10_restore.sql|04_restore.sql)
        for pre in "$art"/*-pre-drop-dump.sql; do
          [ -f "$pre" ] || continue
          db=$(basename -- "$pre" -pre-drop-dump.sql)
          "$MARIADB" --default-character-set=utf8mb4 --force --socket="$SOCKET" -uroot "$db" < "$pre" >> "$out" 2>&1 || :
        done
        ;;
    esac
  done
  executed_list=$(join_by ', ' "${executed[@]}")

  # 4. general.log -> artifacts/general.log и фильтрация служебных строк.
  cp_err=$(cp -- "$GENERAL_LOG" "$gen_copy" 2>&1)
  cprc=$?
  if [ "$cprc" -ne 0 ]; then
    warn "$lab: не удалось скопировать general.log: $cp_err"
    fatal_reasons+=("копирование general.log: $cp_err")
    : > "$gen_copy"
  fi
  if [ ! -s "$gen_copy" ]; then
    warn "$lab: general.log пуст — проверьте general_log_file сервера"
    fatal_reasons+=("general.log пуст")
  fi
  grep -aviE "$FILTER_RE" "$gen_copy" > "$actions" 2>/dev/null || :
  [ -f "$actions" ] || : > "$actions"

  # 5. Поиск БД: CREATE DATABASE / CREATE SCHEMA / USE в SQL плюс env LAB_DBS.
  db_list=()
  while IFS= read -r db; do
    [ -n "$db" ] || continue
    case "${db,,}" in
      mysql|information_schema|performance_schema|sys|'') continue ;;
    esac
    db_list+=("$db")
  done < <(
    {
      if [ -n "${LAB_DBS:-}" ]; then
        printf '%s\n' "${LAB_DBS//,/ }"
      fi
      if [ "${#sql_files[@]}" -gt 0 ]; then
        awk '
          function emit(token,   n, a, i, name) {
            n = split(token, a, /[[:space:]`"]+/)
            name = ""
            for (i = 1; i <= n; i++) if (a[i] != "") name = a[i]
            if (name != "" && name != "if" && name != "not" && name != "exists")
              print name
          }
          {
            line = $0
            sub(/--.*/, "", line)
            sub(/#.*/, "", line)
            sub(/^[[:space:]]+/, "", line)
            low = tolower(line)
            # Только начала выражений: иначе текст вида "Use indexes" внутри
            # строковых литералов ошибочно принимался бы за имя БД.
            if (match(low, /^create[[:space:]]+(database|schema)[[:space:]]+(if[[:space:]]+not[[:space:]]+exists[[:space:]]+)?[a-z0-9_`$"]+/))
              emit(substr(line, RSTART, RLENGTH))
            if (match(low, /^use[[:space:]]+[a-z0-9_`$"]+/))
              emit(substr(line, RSTART, RLENGTH))
          }
        ' "${sql_files[@]}"
      fi
    } | awk 'NF && !seen[$0]++'
  )

  for db in "${db_list[@]}"; do
    safe_db=${db//\'/\'\'}
    exists=$("$MARIADB" --default-character-set=utf8mb4 --socket="$SOCKET" -uroot -N -B \
      -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$safe_db'" 2>/dev/null)
    if [ "$exists" != "1" ]; then
      skipped_dbs+=("$db")
      continue
    fi
    dump_file="$art/${db}-dump.sql"
    # Важно: только MariaDB-совместимые флаги. Никаких --set-gtid-purged,
    # --column-statistics, --no-tablespaces и прочих MySQL-ONLY опций.
    dump_err=$("$MYSQLDUMP" --socket="$SOCKET" -uroot \
      --single-transaction --skip-set-charset "$db" > "$dump_file" 2>&1)
    drc=$?
    if [ "$drc" -eq 0 ]; then
      dump_names+=("$db")
      dump_sizes+=("$(wc -c < "$dump_file" 2>/dev/null || printf '0')")
    else
      warn "$lab: дамп БД $db завершился с кодом $drc: $dump_err"
      fatal_reasons+=("дамп $db: exit=$drc")
      {
        printf '===== DUMP %s : exit=%d =====\n' "$db" "$drc"
        printf '%s\n' "$dump_err"
      } >> "$out"
      rm -f -- "$dump_file"
    fi
  done

  # 6. Короткий RESULT.txt.
  gen_size=$(wc -c < "$gen_copy" 2>/dev/null || printf '0')
  act_lines=$(wc -l < "$actions" 2>/dev/null || printf '0')
  dump_total=0
  for s in "${dump_sizes[@]}"; do dump_total=$((dump_total + ${s:-0})); done
  err_count=$(grep -Eic "$ERR_RE" "$out" 2>/dev/null || true)
  err_sample=$(grep -Ei "$ERR_RE" "$out" 2>/dev/null | sort -u | head -n 20)

  {
    printf 'Дата: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf 'Лабораторная: %s\n' "$lab"
    printf 'SQL-файлы (%d): %s\n' "${#executed[@]}" "$executed_list"
    if [ "${#file_rcs[@]}" -gt 0 ]; then
      printf 'Коды возврата: %s\n' "$(join_by ', ' "${file_rcs[@]}")"
    else
      printf 'Коды возврата: нет выполненных файлов\n'
    fi
    printf 'Общий код возврата: %d\n' "$overall_rc"
    printf 'Размер general.log: %s байт (%s)\n' "$gen_size" "$(human_bytes "$gen_size")"
    printf 'Размер execution-output.txt: %s байт\n' "$(wc -c < "$out" 2>/dev/null || printf '0')"
    printf 'Строк в my_actions.log: %s\n' "$act_lines"
    printf 'Дампы (%d), всего %s байт (%s)\n' "${#dump_names[@]}" "$dump_total" "$(human_bytes "$dump_total")"
    if [ "${#dump_names[@]}" -gt 0 ]; then
      for i in "${!dump_names[@]}"; do
        printf '  %s: %s байт\n' "${dump_names[$i]}" "${dump_sizes[$i]}"
      done
    fi
    if [ "${#skipped_dbs[@]}" -gt 0 ]; then
      printf 'Пропущены несуществующие БД: %s\n' "$(join_by ', ' "${skipped_dbs[@]}")"
    fi
    printf 'Ошибок в execution-output.txt: %s (показаны первые 20 уникальных)\n' "$err_count"
    if [ -n "$err_sample" ]; then printf '%s\n' "$err_sample"; else printf '  нет\n'; fi
    if grep -Eiq "$FATAL_RE" "$out" 2>/dev/null; then
      fatal_reasons+=("фатальные ошибки подключения/доступа в execution-output.txt")
    fi
    if [ "${#fatal_reasons[@]}" -eq 0 ]; then
      printf 'Фатальные ошибки: нет\n'
    else
      printf 'Фатальные ошибки: %s\n' "$(join_by '; ' "${fatal_reasons[@]}")"
    fi
  } > "$result"

  if [ "${#fatal_reasons[@]}" -eq 0 ]; then
    status="OK"; ok_labs=$((ok_labs + 1))
  else
    status="FATAL"
  fi
  sum_lab+=("$lab")
  sum_sql+=("${#sql_files[@]}")
  sum_act+=("$act_lines")
  sum_dump+=("${#dump_names[@]}")
  sum_size+=("$(human_bytes "$gen_size")")
  sum_status+=("$status")
  printf '[%s] готово: %s (SQL=%d, дампов=%d, строк лога=%s)\n' \
    "$lab" "$status" "${#sql_files[@]}" "${#dump_names[@]}" "$act_lines"
done

# ---------------------------------------------------------------------------
# 7. Сводная таблица и код возврата
# ---------------------------------------------------------------------------
printf '\n========== СВОДКА ==========\n'
printf '%-26s %5s %6s %7s %10s %s\n' 'ЛАБОРАТОРНАЯ' 'SQL' 'СТРОК' 'ДАМПОВ' 'GENERAL.LOG' 'СТАТУС'
printf '%-26s %5s %6s %7s %10s %s\n' '--------------------------' '-----' '------' '-------' '----------' '------'
for i in "${!sum_lab[@]}"; do
  printf '%-26s %5s %6s %7s %10s %s\n' \
    "${sum_lab[$i]}" "${sum_sql[$i]}" "${sum_act[$i]}" "${sum_dump[$i]}" "${sum_size[$i]}" "${sum_status[$i]}"
done
printf '\nЛабораторных без фатальных ошибок: %d из %d (порог: 12)\n' "$ok_labs" "${#lab_dirs[@]}"
if [ "$ok_labs" -ge 12 ]; then
  printf 'ИТОГ: порог достигнут.\n'
  exit 0
fi
printf 'ИТОГ: порог не достигнут.\n' >&2
exit 1
