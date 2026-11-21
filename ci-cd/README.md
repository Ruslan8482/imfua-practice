### [Вернуться на Главную](../README.md)

## Навигация

- [Реестр заданий](../TASKS.md)
- [Архитектура](../ARCHITECTURE.md)

# CI/CD в GitHub Actions

19 workflow-файлов из [раздела CI/CD](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/README.md)
расположены в [`../.github/workflows`](../.github/workflows).
Исходники и тесты для пайплайнов — в `pipelines/<имя>/`.

## 🧰 Группы

- **CI:** hello, Python, Node.js/TypeScript, Go, Rust (2 варианта), PHP+MySQL, C++, Java.
- **CI/CD с публикацией:** Rust/Go → GHCR; Go/Python/.NET/Go GUI → GitHub Releases.
- **Deploy:** статический сайт на GitHub Pages (2 варианта).

## 🧰 Как использовать

1. Скопируйте репозиторий в свой GitHub-аккаунт (push выполняете сами, в этой среде он не делался).
2. Workflow автоматически подхватятся из `.github/workflows/`.
3. Для публикации артефактов задайте permissions `packages: write` / `contents: write`
   (уже прописаны в соответствующих файлах).
4. Для GitHub Pages включите `Settings → Pages → Source: GitHub Actions`.

Workflow с `*BIN*` публикуют бинарники только по `tag` (`v*`) — создайте тег локально и
отправьте его в свой репозиторий при необходимости.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
