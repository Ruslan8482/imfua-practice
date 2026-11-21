#!/usr/bin/env bash
# Статическая проверка репозитория: структура, BOM/CRLF, обязательные файлы.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
warn() { echo "WARN: $*"; }
err()  { echo "ERROR: $*"; fail=$((fail+1)); }

echo "==> Проверка обязательных каталогов"
for d in database docker/image-library docker/dockerfile docker/compose ci-cd/pipelines \
         .github/workflows scripts docs database/_shared database/logs database/dumps; do
  [ -d "$d" ] || err "отсутствует каталог $d"
done

echo "==> Проверка лабораторных (README.md + commands.sh + SQL)"
labs=$(find database -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9]-*' | sort)
lab_count=0
for lab in $labs; do
  lab_count=$((lab_count+1))
  for f in README.md commands.sh; do
    [ -f "$lab/$f" ] || err "$lab: отсутствует $f"
  done
  if ! find "$lab" -maxdepth 1 -name '*.sql' | grep -q .; then
    err "$lab: нет SQL-скриптов"
  fi
done
[ "$lab_count" -eq 16 ] || warn "ожидалось 16 лабораторных, найдено $lab_count"

echo "==> Проверка заданий Docker"
for track in image-library dockerfile compose; do
  n=$(find "docker/$track" -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9]-*' | wc -l)
  echo "  $track: $n заданий"
  for task in docker/$track/[0-9][0-9]-*; do
    [ -d "$task" ] || continue
    [ -f "$task/README.md" ] || err "$task: отсутствует README.md"
  done
done

echo "==> Проверка workflow"
n=$(find .github/workflows -maxdepth 1 -name '*.yml' | wc -l)
echo "  GitHub Actions: $n workflow"
[ "$n" -gt 0 ] || err "нет workflow-файлов"

echo "==> Проверка кодировки (UTF-8 без BOM, LF) и YAML"
while IFS= read -r -d '' f; do
  case "$f" in
    */artifacts/*|*/evidence/*|*.png|*.jpg) continue ;;
  esac
  if head -c 3 "$f" | od -An -tx1 | grep -q 'ef bb bf'; then
    err "BOM в файле $f"
  fi
  if grep -q $'\r' "$f" 2>/dev/null; then
    err "CRLF в файле $f"
  fi
done < <(find . -type f \( -name '*.sh' -o -name '*.sql' -o -name '*.cnf' -o -name '*.md' -o -name '*.yml' -o -name 'Dockerfile' \) -print0)

python3 - <<'PY' || fail=$((fail+1))
import pathlib, sys
try:
    import yaml  # type: ignore
except ImportError:
    print("WARN: PyYAML не установлен, проверка YAML пропущена")
    sys.exit(0)
bad = 0
for p in pathlib.Path(".github/workflows").glob("*.yml"):
    try:
        yaml.safe_load(p.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"ERROR: неверный YAML {p}: {e}")
        bad += 1
sys.exit(1 if bad else 0)
PY

echo
if [ "$fail" -eq 0 ]; then
  echo "ПРОВЕРКА ПРОЙДЕНА"
else
  echo "ПРОВЕРКА НЕ ПРОЙДЕНА: ошибок $fail"
fi
exit "$fail"
