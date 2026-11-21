.PHONY: help check init list-labs run-lab stop-lab clean

ROOT := $(CURDIR)

help: ## Показать список команд
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

init: ## Инициализировать локальный git-репозиторий (без remote и push)
	git init
	@echo "Репозиторий инициализирован. Remote и push не выполнялись."

check: ## Проверить структуру, кодировки и обязательные файлы
	bash scripts/check.sh

list-labs: ## Показать все лабораторные
	@find database -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9]-*' | sort

run-lab: ## Запустить БД для лабораторной: make run-lab LAB=01-lesson-1
	bash scripts/run-lab.sh $(LAB)

stop-lab: ## Остановить и удалить контейнер лабораторной: make stop-lab LAB=01-lesson-1
	@docker rm -f "imfua-$(LAB)" 2>/dev/null || true

clean: ## Удалить локальные логи/дампы/скриншоты
	find . -type f \( -name '*.log' -o -name '*-dump.sql' \) -delete
	@echo "Локальные артефакты удалены."
