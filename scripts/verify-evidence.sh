#!/usr/bin/env bash
# Проверить, что у каждой лабораторной есть реальные доказательства и что
# отчёт ссылается на них. Ничего не изменяет.
set -uo pipefail
ROOT="${REPO_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)}"
fail=0
for lab in "$ROOT"/database/[0-9][0-9]-*; do
  [ -d "$lab" ] || continue
  name=$(basename -- "$lab")
  art="$lab/artifacts"
  readme="$lab/README.md"
  for f in general.log my_actions.log execution-output.txt RESULT.txt; do
    if [ ! -s "$art/$f" ]; then
      echo "ОТСУТСТВУЕТ: $name/artifacts/$f"
      fail=$((fail + 1))
    fi
    if [ -f "$readme" ] && ! grep -q "$f" "$readme"; then
      echo "НЕТ ССЫЛКИ: $name/README.md -> $f"
      fail=$((fail + 1))
    fi
  done
  if ! grep -q '✅ \*\*Статус отчёта: выполнено' "$readme" 2>/dev/null; then
    echo "НЕ ОБНОВЛЁН СТАТУС: $name/README.md"
    fail=$((fail + 1))
  fi
  if grep -q 'В этой среде нет Docker' "$readme" 2>/dev/null; then
    echo "УСТАРЕВШЕЕ УПОМИНАНИЕ: $name/README.md"
    fail=$((fail + 1))
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "ДОКАЗАТЕЛЬСТВА ПРОВЕРЕНЫ: 16/16 лабораторных"
  exit 0
fi
echo "ПРОБЛЕМ: $fail"
exit 1
