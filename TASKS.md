### [Вернуться на Главную](README.md)

## Навигация

- [Реестр заданий](TASKS.md)
- [Архитектура](ARCHITECTURE.md)

# Реестр заданий

> Источник задач: [rurewa/imfua](https://github.com/rurewa/imfua).
> Статус `выполнено` (БД 01–16) = лабораторная реально выполнена локальным MariaDB 11.4.14,
> логи и дампы лежат в `database/NN-*/artifacts/`.
> Статус `подготовлено, требуется запуск` = каталог, скрипты и конфиги готовы; для Docker-заданий
> нужен Docker, для скриншотов — GUI. Workflow из `.github/workflows/` запущены в GitHub Actions.

## 1. Основы проектирования баз данных (Практика) — `database/`

| № | Каталог | Задание | Источник |
|---|---------|---------|----------|
| 01 | `01-lesson-1` | SQL-команды для создания и заполнения нормализованных таблиц | [Lesson_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Lesson_1.md) |
| 02 | `02-begin-mysql-1` | Интерактивная работа с MySQL в Docker № 1 | [Begin_MySQL_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_1.md) |
| 03 | `03-begin-mysql-2` | Интерактивная работа с MySQL в Docker № 2 | [Begin_MySQL_2.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Begin_MySQL_2.md) |
| 04 | `04-products` | Основные операции: `products 1` и `products 2` | [Products.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Products.md) |
| 05 | `05-view-mysql` | Руководство по представлениям (VIEW) в MySQL | [VIEW_MySQL.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/VIEW_MySQL.md) |
| 06 | `06-normalization-1` | Лабораторная № 1 по нормализации (с логом) | [Normalization_1.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_1.md) |
| 07 | `07-normalization-2` | Лабораторная № 2 по нормализации (с логом) | [Normalization_2.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_2.md) |
| 08 | `08-normalization-3` | Лабораторная № 3 по нормализации (с логом) | [Normalization_3.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_3.md) |
| 09 | `09-normalization-4` | Лабораторная № 4 по нормализации (с логом) | [Normalization_4.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_4.md) |
| 10 | `10-normalization-5` | Лабораторная № 5 по нормализации (с логом) | [Normalization_5.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization_5.md) |
| 11 | `11-aliases` | Лабораторная по алиасам в MySQL | [Aliases.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Aliases.md) |
| 12 | `12-index` | Индексы в MySQL (с логом) | [Index.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index.md) |
| 13 | `13-fulltext` | FULLTEXT-поиск в MySQL | [FULLTEXT.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/FULLTEXT.md) |
| 14 | `14-order-by-group-by` | Ускорение ORDER BY / GROUP BY | [ORDER_BY_GROUP_BY.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/ORDER_BY_GROUP_BY.md) |
| 15 | `15-index-join` | Индексы и JOIN | [Index_JOIN.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Index_JOIN.md) |
| 16 | `16-normalization-common` | Нормализация: аномалии → 3NF (общая лабораторная) | [Normalization.md](https://github.com/rurewa/imfua/blob/main/content/Courses/Basics_database_design/content/bd/Normalization.md) |

## 2. Docker CLI / ImageLibrary — `docker/image-library/`

| № | Каталог | Образ | Источник |
|---|---------|-------|----------|
| 01 | `01-dockerhub` | DockerHub | [DockerHub.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/DockerHub.md) |
| 02 | `02-nginx` | Nginx | [Nginx.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Nginx.md) |
| 03 | `03-welcome-to-docker` | Welcome to Docker | [WelcomeToDocker.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/WelcomeToDocker.md) |
| 04 | `04-apache` | Apache | [Apache.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Apache.md) |
| 05 | `05-adminer` | Adminer | [Adminer.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Adminer.md) |
| 06 | `06-alt-linux` | Alt Linux | [AltInDocker.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/AltInDocker.md) |
| 07 | `07-apache-static-site` | Статический сайт на Apache | [Apache+StaticSite.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Apache+StaticSite.md) |
| 08 | `08-metasploitable2` | Metasploitable2 | [Metasploitable2.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Metasploitable2.md) |
| 09 | `09-postgresql` | PostgreSQL | [PostgreSQL.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/PostgreSQL.md) |
| 10 | `10-redis` | Redis | [Redis.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Redis.md) |
| 11 | `11-ubuntu` | Ubuntu | [Ubuntu.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Ubuntu.md) |
| 12 | `12-python` | Python | [Python.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Python.md) |
| 13 | `13-node-js` | Node.js | [Node.jsForJS.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Node.jsForJS.md) |
| 14 | `14-mysql` | MySQL | [MySQL.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/MySQL.md) |
| 15 | `15-mongodb` | MongoDB | [MongoDB.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/MongoDB.md) |
| 16 | `16-portainer` | Portainer | [Portainer.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Portainer.md) |
| 17 | `17-http-file-server` | HTTP-сервер раздачи файлов | [HTTPserverFiles.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/HTTPserverFiles.md) |
| 18 | `18-cadvisor` | cAdvisor | [cAdvisor.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/cAdvisor.md) |
| 19 | `19-speedtest` | Speedtest | [speedtest.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/speedtest.md) |
| 20 | `20-file-server` | Файловый обменник | [file-server.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/file-server.md) |
| 21 | `21-jira` | Jira | [Jira.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Jira.md) |
| 22 | `22-pcb2gcode` | Pcb2gcode | [Pcb2gcode.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Pcb2gcode.md) |
| 23 | `23-ollama` | Ollama / Open WebUI | [Ollama.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/Ollama.md) |
| 24 | `24-libredb-studio` | LibreDB Studio | [LibreDB_Studio.md](https://github.com/rurewa/imfua/blob/main/content/Docker/ImageLibrary/LibreDB_Studio.md) |

## 3. Dockerfile — `docker/dockerfile/`

| № | Каталог | Задание | Источник |
|---|---------|---------|----------|
| 01 | `01-hello-world` | Привет, Docker! | [hello-world.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/hello-world.md) |
| 02 | `02-nginx-static-site` | Статический сайт на Nginx | [my-site.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/my-site.md) |
| 03 | `03-python` | Простое приложение на Python | [Python.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Python.md) |
| 04 | `04-flask-python` | Flask + Python (мини-проект) | [Flask+Python_Mini.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Flask+Python_Mini.md) |
| 05 | `05-dotnet` | C# (.NET) с публикацией | [dotNet.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/dotNet.md) |
| 06 | `06-cpp` | Консольное приложение на C++ | [cpp.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cpp.md) |
| 07 | `07-cpp-ftxui` | C++ и FTXUI | [ftxui.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/ftxui.md) |
| 08 | `08-cpp-ftxui-wow` | Псевдографическое C++ и FTXUI | [ftxui_wow.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/ftxui_wow.md) |
| 09 | `09-cpp-fltk` | Оконное приложение C++/FLTK | [cpp_fltk.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cpp_fltk.md) |
| 10 | `10-rust` | Приложение на Rust | [Rust.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Rust.md) |
| 11 | `11-ruby` | Приложение на Ruby | [Ruby.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Ruby.md) |
| 12 | `12-php` | Приложение на PHP | [php.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/php.md) |
| 13 | `13-node-js` | Node.js | [Node_js.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Node_js.md) |
| 14 | `14-typescript` | Приложение на TypeScript | [TypeScript.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/TypeScript.md) |
| 15 | `15-pascal` | Pascal | [Pascal.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/Pascal.md) |
| 16 | `16-java` | Java | [java.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/java.md) |
| 17 | `17-cpp-qt5` | Qt5 / C++ | [cppQt5.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cppQt5.md) |
| 18 | `18-cpp-qt6` | Qt6 / C++ | [cppQt6.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/cppQt6.md) |
| 19 | `19-postgres-adminer` | PostgreSQL + Adminer (самостоятельно) | [README.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md) |
| 20 | `20-postgres-pgadmin` | PostgreSQL + pgAdmin (самостоятельно) | [README.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md) |
| 21 | `21-postgres-cloudbeaver` | PostgreSQL + CloudBeaver (самостоятельно) | [README.md](https://github.com/rurewa/imfua/blob/main/content/Docker/Dockerfile/README.md) |

## 4. Docker Compose — `docker/compose/`

| № | Каталог | Задание | Источник |
|---|---------|---------|----------|
| 01 | `01-joomla` | Joomla | [joomla.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/joomla.md) |
| 02 | `02-wordpress` | WordPress | [WordPress.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/WordPress.md) |
| 03 | `03-mysql-phpmyadmin` | MySQL + phpMyAdmin | [mySQLphpMyAdmin.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/mySQLphpMyAdmin.md) |
| 04 | `04-postgresql` | PostgreSQL | [PostgresSQL.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgresSQL.md) |
| 05 | `05-postgres-pgadmin` | PostgreSQL + pgAdmin | [PostgreSQL_pgAdmin.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/PostgreSQL_pgAdmin.md) |
| 06 | `06-drawdb` | drawDB | [drawDB.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/drawDB.md) |
| 07 | `07-libredb-studio` | LibreDB Studio | [LibreDB_Studio.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/LibreDB_Studio.md) |
| 08 | `08-homehub` | Homehub | [Homehub.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/Homehub.md) |
| 09 | `09-cloudbeaver` | CloudBeaver | [CloudBeaver.md](https://github.com/rurewa/imfua/blob/main/content/Docker/DockerCompose/CloudBeaver.md) |

## 5. CI/CD GitHub Actions — `.github/workflows/`

| № | Workflow | Задание | Источник |
|---|----------|---------|----------|
| 01 | `ci-hello.yml` | Первый Pipeline | [hello.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/hello.md) |
| 02 | `ci-python.yml` | Пайплайн для Python | [Python.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Python.md) |
| 03 | `ci-nodejs.yml` | Node.js / TypeScript REST API | [NodeJS.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/NodeJS.md) |
| 04 | `ci-go.yml` | Go | [Go.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Go.md) |
| 05 | `ci-rust-cli.yml` | Rust CLI: тесты и линтинг | [Rust_CI_1.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Rust_CI_1.md) |
| 06 | `ci-php-mysql.yml` | PHP + MySQL | [PHP.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/PHP.md) |
| 07 | `ci-cpp.yml` | C++ | [cpp.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/cpp.md) |
| 08 | `ci-java.yml` | Hello Java! | [hello_java.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/hello_java.md) |
| 09 | `ci-rust-cli-1.yml` | Pipeline CI на Rust (вариант 1) | [Rust_CI_1.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Rust_CI_1.md) |
| 10 | `cd-rust-ghcr.yml` | Rust CLI → GHCR | [CI_CD_Rust.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_Rust.md) |
| 11 | `cd-go-ghcr.yml` | Go CLI → GHCR | [CI_CD_Go.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_Go.md) |
| 12 | `cd-go-bin.yml` | Go CLI → GitHub Releases | [Go_bin.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Go_bin.md) |
| 13 | `cd-python-pyinstaller-bin.yml` | Python + PyInstaller → Releases | [Python_PyInstaller_bin.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Python_PyInstaller_bin.md) |
| 14 | `cd-dotnet-bin.yml` | C#/.NET CLI → Releases | [Dotnet.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Dotnet.md) |
| 15 | `cd-go-gui-bin.yml` | Go GUI → Releases | [CD_Go_GUI.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CD_Go_GUI.md) |
| 16 | `cd-hexloader-bin.yml` | Hex Loader → Releases | [HexLoader.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/HexLoader.md) |
| 17 | `cd-arduino-manager-bin.yml` | Arduino Manager (Fyne) → Releases | [ArduinoManager.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/ArduinoManager.md) |
| 18 | `cd-static-site-pages.yml` | Статический сайт → GitHub Pages | [CI_CD_static_site_Deploy.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_CD_static_site_Deploy.md) |
| 19 | `cd-github-pages.yml` | GitHub Pages (вариант 2) | [CI_Deploy_GitHub_Pages.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/CI_Deploy_GitHub_Pages.md) |

Итого: 16 + 24 + 21 + 9 + 19 = **89 заданий**.

> Если вы обнаружили ошибку в этом тексте - сообщите пожалуйста автору!
