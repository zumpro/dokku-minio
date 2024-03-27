![](.github/images/repo_header.png)

[![Minio](https://img.shields.io/badge/Minio-15/03/2024-blue.svg)](https://github.com/minio/minio/releases/tag/RELEASE.2024-03-15T01-07-19Z)
[![Dokku](https://img.shields.io/badge/Dokku-Repo-blue.svg)](https://github.com/dokku/dokku)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/zumpro/dokku-minio/graphs/commit-activity)

# Запуск Minio на Dokku

## Привилегии

### Что такое Mini?

Minion - это сервер хранения объектов, совместимый по API с облачным сервисом хранения Amazon S3. Вы можете найти более подробную информацию о Minion на [minio.io](https://www.minio.io/) website.

### Что такое Докку?

[Dokku](http://dokku.viewdocs.io/dokku/) - это облегченная реализация платформы как сервиса (PaaS), работающая на базе Docker. Ее можно рассматривать как мини-Heroku.

### Требования
* A working [Dokku host](http://dokku.viewdocs.io/dokku/getting-started/installation/)
* [Letsencrypt](https://github.com/dokku/dokku-letsencrypt) plugin for SSL (optionnal)

# Настройка

**Примечание:** На протяжении всего этого руководства мы будем использовать домен `minio.example.com` в демонстрационных целях. Обязательно замените его вашим фактическим доменным именем.

## Создайте приложение

Войдите на свой хостинг Dokku и создайте приложение Minion:

```bash
dokku apps:create minio
```

## Конфигурация

### Настройка пользователя root

Mini использует комбинацию имени пользователя и пароля (`MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`) для аутентификацию и управление объектами. Установите эти переменные среды с помощью следующих команд:

```bash
dokku config:set minio MINIO_ROOT_USER=<username>
dokku config:set minio MINIO_ROOT_PASSWORD=<password>
```

### Увеличьте ограничение на размер загружаемого файла

Чтобы изменить лимит загрузки, вам необходимо настроить переменную окружения `CLIENT_MAX_BODY_SIZE`, используемую Dokku. В этом примере мы установили для нее максимальное значение в 10 МБ:

```bash
dokku config:set minio CLIENT_MAX_BODY_SIZE=10M
```

## Постоянное хранилище

Чтобы гарантировать, что загруженные данные сохраняются между перезапусками, мы создаем папку на хост-компьютере, предоставляем права на запись пользователю, определенному в Dockerfile, и инструктируем Dokku подключить ее к контейнеру приложения. Выполните следующие действия:

```bash
dokku storage:ensure-directory minio --chown false
dokku storage:mount minio /var/lib/dokku/data/storage/minio:/data
```

## Настройка домена

Чтобы включить маршрутизацию для приложения Minio, нам необходимо настроить домен. Выполните следующую команду:

```bash
dokku domains:set minio minio.example.com
```

## Переместите Minio в Dokku

### Захватите репозиторий

Начните с клонирования этого репозитория на свой локальный компьютер.

#### Через SSH

```bash
git clone git@github.com:zumpro/dokku-minio.git
```

#### Через HTTPS

```bash
git clone https://github.com/zumpro/dokku-minio.git
```

### Настройка git remote

Теперь настройте свой сервер Dokku в качестве удаленного хранилища.

```bash
git remote add dokku dokku@example.com:minio
```

### Push Minio

Теперь вы можете загрузить приложение Minion в Dokku. Убедитесь, что вы выполнили этот шаг, прежде чем переходить к [next section](#ssl-certificate).

```bash
git push dokku master
```

## SSL-сертификат

Наконец, давайте получим SSL-сертификат от [Let's Encrypt](https://letsencrypt.org/).

```bash
# Install letsencrypt plugin
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Set certificate contact email
dokku letsencrypt:set minio email you@example.com

# Generate certificate
dokku letsencrypt:enable minio
```

## Подведение итогов

Поздравляю! Ваш экземпляр Minion теперь запущен, и вы можете получить к нему доступ по адресу [https://minio.example.com](https://minio.example.com).

## Мини-веб-консоль

Чтобы получить доступ к веб-консоли Minio и управлять своими файлами, вам необходимо настроить необходимые параметры прокси-сервера. Следующие команды помогут вам настроить его:

```bash
# If ssl enabled
dokku proxy:ports-add minio https:<desired_port>:9001

# If ssl disabled (note scheme change)
dokku proxy:ports-add minio http:<desired_port>:9001
```

Замените `<желаемый порт>` на номер порта, который вы предпочитаете. По умолчанию Minio использует порт `9001`.

После настройки прокси-сервера вы можете получить доступ к веб-консоли Minion, посетив [https://minio.example.com:9001](https://minio.example.com:9001) в вашем веб-браузере.

### Проблема с общими ссылками веб-консоли

Чтобы устранить проблему со ссылками общего доступа, сгенерированными консолью, указывающими на IP-адрес контейнера Docker вместо вашего экземпляра Minion, вы можете использовать следующую команду:

```bash
dokku config:set minio \
  MINIO_SERVER_URL=https://minio.example.com \
  MINIO_BROWSER_REDIRECT_URL=https://minio.example.com:9001
```

Эта команда устанавливает соответствующие переменные среды, чтобы гарантировать, что ссылки общего доступа правильно указывают на ваш экземпляр Minion по адресу https://minio.example.com и используют настроенный порт.

Теперь вы готовы использовать Minion и использовать его мощные функции для ваших нужд хранения. Счастливого управления файлами!
