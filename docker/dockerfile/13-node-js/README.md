### [Вернуться на Главную](../../../README.md)

## Навигация

- [Реестр заданий](../../../TASKS.md)
- [Архитектура](../../../ARCHITECTURE.md)
- [Источник](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Node_js.md)

# 13. Dockerfile. Node.js

## 🎯 Цель

Собрать и запустить учебный образ по инструкции источника, зафиксировать команды
и результат в этом каталоге.

## 🔗 Источник

- Оригинал: [Node_js.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Node_js.md)
- Реестр заданий: [TASKS.md](../../../TASKS.md)

## 🧰 Структура каталога

```text
13-node-js/
├── Dockerfile
├── .dockerignore
├── README.md
├── commands.sh
├── package.json
└── index.js
```

## 📋 Сборка и запуск

```bash
cd docker/dockerfile/13-node-js
docker build -t imfua-node .
docker run -d -p 3000:3000 --name imfua-node imfua-node
```

## ✅ Проверка

```bash
curl -f http://localhost:3000/
```

Или откройте <http://localhost:3000>. Ожидаемый ответ:
`Hello from Node.js in Docker! 🐳`.

## 🧰 Порты

Хост `3000` → контейнер `3000` (Express).



## 📊 Результаты

- Статус сборки: `НЕ ВЫПОЛНЯЛАСЬ (в этой среде нет Docker)`
- Имя образа: `imfua-node`
- ID запущенного контейнера: `<вставить docker ps / CID>`
- Вывод команды проверки: `<вставить сюда реальный вывод>`
- Замечания: `<если были отличия от инструкции — описать>`

### Скриншот

![Результат выполнения задания](evidence/screenshot.png)

> **Внимание:** в этой среде нет Docker, реальная сборка и запуск не выполнялись. Все шаги ниже проверены только статически; реальные логи и скриншоты добавляются на машине с Docker.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
