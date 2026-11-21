### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Python_PyInstaller_bin.md)

# Python CLI → GitHub Releases (`cd-python-pyinstaller-bin.yml`)

Источник: [Python_PyInstaller_bin.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Python_PyInstaller_bin.md)

## 🎯 Что делает пайплайн

1. Запускается по тегу `v*` (или вручную).
2. Прогоняет pytest на Ubuntu.
3. Собирает `--onefile` бинарник отдельно на Ubuntu, macOS и Windows (кросс-компиляции для Python нет).
4. Упаковывает результаты в `.tar.gz` / `.zip` и публикует в Release.

## 📋 Локальный запуск

```bash
pip install -r requirements.txt pytest pyinstaller
python -m pytest -v
python -m PyInstaller --onefile --name cli src/cli.py
./dist/cli CI
```

## 📸 Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** и страницы Release.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
