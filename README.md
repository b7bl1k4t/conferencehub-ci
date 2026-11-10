# ConferenceHub — учебный CI/CD

Базовый вариант ПР4: имитация сборки и поставки ConferenceHub в Jenkins.
Функции приложения из ПР1–ПР3 здесь не реализованы. Build создаёт текстовый
артефакт с названием проекта, номером сборки и Git commit; Test проверяет его
содержимое; deploy копирует тот же артефакт в отдельное окружение; smoke-tests
сравнивает копию с исходным файлом.

## Файлы

| Файл | Назначение |
|---|---|
| Jenkinsfile | Checkout → Build → Test → Staging → Smoke → Approval → Prod |
| build.sh | Создание `dist/conferencehub-release.txt` |
| test.sh | Проверка метаданных текущей сборки |
| deploy | Имитация поставки в `staging` или `prod` |
| smoke-tests | Проверка совпадения поставленного и собранного артефактов |
| .gitattributes | Окончания строк LF для скриптов и Jenkinsfile |

## Запуск в Jenkins

Нужен Linux executor с Git и POSIX sh. Для учебного запуска используется
встроенный узел Jenkins в официальном контейнере `jenkins/jenkins:lts-jdk21`;
`JENKINS_HOME` должен быть задан и доступен на запись. Установить Pipeline и Git.
Если требуется почта, установить Mailer и Pipeline: Basic Steps и настроить SMTP.

Загрузить содержимое этой папки в корень своего GitHub-репозитория. Создать
задание Pipeline → Pipeline script from SCM → Git, ветка `*/main`, Script Path
`Jenkinsfile`. Нажать Build Now; в Approval подтвердить Deploy в течение 10 минут.
`NOTIFY_EMAIL` оставить пустым, пока SMTP не настроен. Первый запуск может
показывать Build Now; после загрузки параметров — Build with Parameters.

Staging и prod — каталоги `$JENKINS_HOME/pr4-deploy/conferencehub/`.
Они сохраняются при очистке workspace. Использовать один учебный job для этих
каталогов. `deleteDir()` очищает только workspace после архивации артефакта.
Это имитация развёртывания: HTTP-сервис, база данных и видеосервис не запускаются.

## Локальная проверка без Jenkins

Из этой папки выполнить:

```sh
export BUILD_NUMBER=local-check
export GIT_COMMIT=local-unversioned
export DEPLOY_ROOT="$(mktemp -d /tmp/conferencehub-pr4.XXXXXX)"
sh build.sh
sh test.sh
sh deploy staging
sh smoke-tests staging
# Следующая команда локально заменяет действие после подтверждения в Jenkins.
sh deploy prod
sh smoke-tests prod
```

`local-unversioned` — отметка локальной проверки, а не хеш Git.
В Jenkins `BUILD_NUMBER` задаётся сборкой, а Jenkinsfile явно переносит
`GIT_COMMIT` из результата `checkout scm` в окружение последующих стадий.
Ручной барьер, архивирование, очистку и обработчики post проверять в самом Jenkins.
