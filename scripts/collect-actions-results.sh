#!/usr/bin/env bash
# Собрать статусы GitHub Actions в ci-cd/GITHUB-ACTIONS.md.
# Нужен GH_TOKEN (classic token со скоупом repo) или GITHUB_TOKEN.
set -uo pipefail
ROOT="${REPO_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)}"
REPO="${GH_REPO:-Ruslan8482/imfua-practice}"
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
OUT="$ROOT/ci-cd/GITHUB-ACTIONS.md"
if [ -z "$TOKEN" ]; then
  echo "Нужен GH_TOKEN или GITHUB_TOKEN" >&2
  exit 2
fi
command -v curl >/dev/null || { echo "Нет curl" >&2; exit 2; }
command -v python3 >/dev/null || { echo "Нет python3" >&2; exit 2; }

API="https://api.github.com/repos/$REPO/actions"
headers=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')

curl -sS "${headers[@]}" "$API/workflows?per_page=100" > /tmp/opencode/gh-workflows.json
curl -sS "${headers[@]}" "$API/runs?per_page=100" > /tmp/opencode/gh-runs.json

python3 - /tmp/opencode/gh-workflows.json /tmp/opencode/gh-runs.json "$OUT" <<'PY'
import json, sys
from datetime import datetime, timezone
wf, runs, out = sys.argv[1], sys.argv[2], sys.argv[3]
workflows = json.load(open(wf))["workflows"]
data = json.load(open(runs))["workflow_runs"]
latest = {}
for r in data:
    k = r["workflow_id"]
    if k not in latest or r["created_at"] > latest[k]["created_at"]:
        latest[k] = r
ok = sum(1 for r in latest.values() if r.get("conclusion") == "success")
lines = [
    "### [Вернуться на Главную](../README.md)", "",
    "## Навигация", "",
    "- [Реестр заданий](../TASKS.md)",
    "- [CI/CD](README.md)", "",
    "# Результаты GitHub Actions", "",
    f"Репозиторий: https://github.com/Ruslan8482/imfua-practice", "",
    f"Последний сбор: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}.",
    f"Успешных workflow: **{ok} из {len(workflows)}**.", "",
    "| Workflow | Файл | Последний запуск | Статус |",
    "|---|---|---|---|",
]
for w in workflows:
    r = latest.get(w["id"])
    status = r.get("conclusion") or r.get("status") if r else "не запускался"
    created = r["created_at"].replace("T", " ")[:19] if r else "—"
    lines.append(f"| {w['name']} | `{w['path'].split('/')[-1]}` | {created} | {status} |")
lines += [
    "", "Запуски с `workflow_dispatch` можно повторить вручную во вкладке Actions.", "",
    "> Если вы обнаружите ошибку в этом тексте - сообщите пожалуйста автору!",
]
text = "\n".join(lines)
open(out, "w").write(text)
print(f"Записано: {out} ({ok}/{len(workflows)} успешных)")
PY
