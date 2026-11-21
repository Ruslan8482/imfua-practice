# Python CI (`ci-python.yml`)

Источник: [Python.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Python.md)

## Что делает пайплайн

1. Запускает `flake8` (критические ошибки + информативная статистика).
2. Запускает `pytest` на Python 3.10, 3.11 и 3.12.
3. Кэширует `pip`-зависимости через `actions/setup-python@v5`.
4. При `push` в main собирает Docker-образ без публикации и делает smoke-тест.

## Локальный запуск

```bash
pip install -r requirements.txt
pip install -e .
python -m pytest -v
flake8 .
```

## Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** в `evidence/workflow.png`.
