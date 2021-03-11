# AlBichutsky_microservices
AlBichutsky microservices repository

# Домашнее задание №12

- Установил последние версии `docker`, `docker-compose`, `docker-machine`:

Установка `docker`:

```bash     
# Подробнее: https://docs.docker.com/engine/install/centos/

yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
docker version 
docker info    # проверяем состояние docker daemon
```

Установка `docker-compose`:

```bash
yum install -y docker-compose
docker-compose version
```

Установка `docker-machine`:

```bash
# Подробнее: https://docs.docker.com/machine/install-machine/

base=https://github.com/docker/machine/releases/download/v0.16.0 &&
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
chmod +x /tmp/docker-machine
# бинарник копируем в /usr/bin или /usr/local/bin/
mv /tmp/docker-machine /usr/bin/docker-machine
```

- Запустил тестовый контейнер, на основе коммита создал образ `alexey/ubuntu-tmp-file`. Вывод команды `docker images` записал в файл `docker-monolith/docker-1.log`. Тамже описал отличие между контейнером и образом на основе вывода комманд:

```bash
 docker inspect <u_container_id>
 docker inspect <u_image_id>
```

### Использование docker

#### Получение сведений о контейнерах и образах

```bash
docker images  # посмотреть список сохраненных образов
docker images -a  # посмотреть список сохраненных образов, включая промежуточныe
docker images -q  # посмотреть id всех образов

docker ps     # посмотреть список запущенных контейнеров
docker ps -a  # посмотреть список всех контейнеров (включая остановленные)
docker ps -q  # посмотреть id всех контейнеров

docker inspect <image>  # получить параметры образа в JSON-формате
docker inspect <container>  # получить параметры контейнера в JSON-формате
docker inspect <container> -f '{{.ContainerConfig.Cmd}}'  # получить значение конкретного параметра контейнера

docker system df  # посмотреть информацию, сколько дискового пространства занято образами, контейнерами, томами и сколько можно удалить

docker logs <container> -f  # посмотреть логи контейнера

docker diff <container>  # посмотреть изменения в файловой системе docker
```

#### Запуск контейнеров

```bash
# docker run = docker create + docker start + docker attach при наличии опции -i  
# (при вызове каждый раз запускается новый контейнер)
# Опции:
# -i, --interractive – запустить контейнер в foreground-режиме
# -d, --detach – запустить контейнер в background-режиме
# -t – создать TTY (запустить терминал)
# --name – присвоить имя контейнеру
# --rm – удалить контейнер после выхода из него

docker run -it <image> /bin/bash # запустить контейнер с TTY в foreground режиме
root@<container_id>:/# echo 'Hello world!' > /tmp/file
root@<container_id>:/# exit

docker run -it -rm <image> /bin/bash 
docker run --name <container> --rm -it <image> bash

docker run -dt <image>  # запустить контейнер с TTY в background режиме

docker start <container>  # запустить остановленный (уже созданный) контейнер

docker attach <container> # присоеденить терминал к созданному контейнеру
root@<u_container_id>:/# cat /tmp/file
Hello world!

docker exec -it <container> bash  # запустить новый процесс bash внутри контейнера
root@<u_container_id>
```

#### Остановка и удаление контейнеров

```bash
docker stop <container>  # остановить контейнер

docker kill $(docker ps -q)  # послать SIGKILL запущенным контейнерам

docker rm <container> # удалить контейнер (если указываем имя - удаляются все с данным именем)
docker rm -f <container>  # удалить работающий контейнер
docker rm $(docker ps -a -q) # удалить все незапущенные контейнеры

docker rmi <image>  # удалить образ, если нет запущенных контейнеров
docker rmi -f <image>  # принудительно удалить образ
docker rmi $(docker images -q) # удалить все сохраненные образы

docker prune  # удалить неиспользуемые данные, см. docker system df
```

- В Yandex Cloud получил токен и проинициализировал папку `Default`:

```bash
yc init
...
```

- В Yandex Cloud создал новый инстанс для docker из образа ubuntu-1804-lts:

```bash
yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub
```

Затем с помощью `docker-machine` проинициализировал на нем docker, указав публичный IP инстанса. 
`Docker-machine` позволяет создать хост c docker-engine и управлять им на локальной или облачной ВМ. В нашем случае мы инициализируем окружение docker на уже созданном инстансе Yandex Cloud.

```bash
docker-machine create \
  --driver generic \
  --generic-ip-address=84.252.129.111 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  docker-host
  
docker-machine env docker-host
eval $(docker-machine env docker-host)  # переключиться для управления хостом "docker-host" в окружении Yandex Cloud
```

### Использование docker-machine

```bash
docker-machine --help  # справка
docker-machine create ...  # создать машину с docker

docker-machine ls  # отобразить список зарегистрированных машин с docker
NAME          ACTIVE   DRIVER    STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        generic   Running   tcp://84.252.129.111:2376           v20.10.5   

docker-machine <имя машины> status  # проверить состояние машины с docker
docker-machine <имя машины> rm  # удалить машину с docker

eval $(docker-machineenv --unset)  # выйти из окружения docker-machine
eval $(docker-machine env <имя машины>)  # переключиться к окружению docker-machine с именем <имя машины>
```

- Создал `Dockerfile` c файлами `mongod.conf`, `start.sh`, `db_config`.  

Dockerfile:

```
FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y mongodb-server ruby-full ruby-bundler ruby-dev build-essential git
RUN git clone -b monolith https://github.com/express42/reddit.git

COPY mongod.conf /etc/mongod.conf
COPY db_config /reddit/db_config
COPY start.sh /start.sh

RUN cd /reddit && rm Gemfile.lock && bundle install
RUN chmod 0777 /start.sh

CMD ["/start.sh"]
```

- Собрал образ и запустил контейнер в Yandex Cloud:

```bash
eval $(docker-machine env docker-host)
docker build -t reddit:latest .
docker images -a
docker run --name reddit -d --network=host reddit:latest
```

Проверяем запуск приложения по ссылке: http://<публичный IP>:9292

- Загрузил образ `reddit:latest` в docker-hub с названием `otus-reddit:1.0`:

```bash
docker login  # авторизуемся в docker-hub
docker tag reddit:latest abichutsky/otus-reddit:1.0
docker push abichutsky/otus-reddit:1.0
```

- Запустил контейнер из образа в docker-hub на локальном хосте:

```bash
# В отдельной консоли
eval $(docker-machine env --unset) # выходим из окружения docker-machine
docker ps -a  # убедимся, что мы в локальном окружении
docker run --name reddit -d -p 9292:9292 abichutsky/otus-reddit:1.0 # запускаем контейнер
```

Проверяем запуск приложения по ссылке: http://localhost:9292

### Задание со *

Автоматизируем установку нескольких инстансов `docker` и запуск в них контейнера с нашим приложением из docker-образа с помощью `Packer`, `Terraform` и `Ansible`.   

Требования:  
- Нужно реализовать в виде прототипа в директории /docker-monolith/infra
- Поднятие инстансов с помощью Terraform, их количество задается переменной;
- Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
- Шаблон пакера, который делает образ с уже установленным Docker.

#### Описание

- Создал шаблон Packer для запекания образа в облаке:

docker.json 

```JSON
{
    "variables": {
           "zone": "ru-central1-a",
           "instance_cores": "2"
       },
    "builders": [
       {
           "type": "yandex",
           "service_account_key_file": "{{user `service_account_key_file`}}",
           "folder_id": "{{user `folder_id`}}",
           "source_image_family": "{{user `source_image_family`}}",
           "image_name": "docker-host-{{timestamp}}",
           "image_family": "ubuntu-docker-host",
           "ssh_username": "ubuntu",
           "platform_id": "standard-v1",
           "zone": "{{user `zone`}}",
           "instance_cores": "{{user `instance_cores`}}",
       "use_ipv4_nat" : "true"
       }
   ],
   "provisioners": [
       {
           "type": "ansible",
           "user": "ubuntu",
           "playbook_file": "{{ pwd }}/ansible/playbooks/install_docker.yml"
       }
   ]
}
```

При создании образа выполняется установка docker c помощью ansible-плейбука:

install_docker.yml

```yaml
---
    - hosts: all
      become: true
    
      tasks:
        - name: Install aptitude using apt
          apt: name=aptitude state=latest update_cache=yes force_apt_get=yes
    
        - name: Install required system packages
          apt: name={{ item }} state=latest update_cache=yes
          loop: [ 'apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common', 'python3-pip', 'virtualenv', 'python3-setuptools']
    
        - name: Add Docker GPG apt Key
          apt_key:
            url: https://download.docker.com/linux/ubuntu/gpg
            state: present
    
        - name: Add Docker Repository
          apt_repository:
            repo: deb https://download.docker.com/linux/ubuntu bionic stable
            state: present
    
        - name: Update apt and install docker-ce
          apt: update_cache=yes name=docker-ce state=latest
    
        - name: Install Docker Module for Python
          pip:
            name: docker
```

Запустил сборку образа:

```bash
cd docker-monolith/infra
packer validate -var-file=packer/variables.json packer/docker.json
packer build -var-file=packer/variables.json packer/docker.json
```

- Создал шаблон terraform для развертывания инстансов с docker в облаке из образа packer:

main.yml

```
provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "vm-app" {
  count = var.count_instance
  name = "reddit-app-${count.index}"  # назначаем имена инстансам с порядковыми номерами
  zone = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

}

  # Cоздаем для ansible динамический файл инвентори ../ansible/inventory.ini c ip-адресами инстансов.
  # Генерация происходит на основе шаблона templates/inventory.tpl. 
  resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      docker_hosts = yandex_compute_instance.vm-app.*.network_interface.0.nat_ip_address
    }
  )
  filename = "../ansible/inventory.ini"

}
```

Количество создаваемых инстансов задаем через переменную в `terraform.tfvars`:

```
variable count_instance {
  # кол-во создаваемых инстансов
  default = "2"
}
```

В процессе выполнения terraform генерирует динамический файл инвентори `../ansible/inventory.ini` с IP-адресами инстансов.  
Пример:

```INI
[docker_hosts]
84.252.131.47
84.252.129.18
```

Сам файл инвентори создается из шаблона `templates/inventory.tpl`:

```
[docker_hosts]
%{ for ip in docker_hosts ~}
${ip}
%{ endfor ~}
```

Создал инстансы через terraform:

```bash
cd docker-monolith/infra/terraform
terraform init # переинициализируем
terraform plan
terraform apply
```

- Создал ansible-плейбук, который делает пулл загруженного ранее образа из docker-hub и запускает контейнер с нашим приложением.

run_app_in_docker.yml

```yml
--
    - hosts: all
      become: true
      
      vars:
        default_container_name: reddit
        default_container_image: abichutsky/otus-reddit:1.0
    
      tasks:
      
        - name: Pull Docker image
          docker_image:
            name: "{{ default_container_image }}"
            source: pull

        - name: Create container
          docker_container:
            name: "{{ default_container_name }}"
            image: "{{ default_container_image }}"
            state: started
            ports:
              - "9292:9292"
          # restart: yes

        - name: Check list of runned containers
          command: docker ps
          register: cont_list
      
        - debug: msg="{{ cont_list.stdout }}"
```

Запуск плейбука:

```bash
cd docker-monolith/infra/ansible
ansible-playbook playbooks/run_app_in_docker.yml
```

Проверка:

```
TASK [debug] *******************************************************************
ok: [84.252.131.47] => {
    "msg": "CONTAINER ID   IMAGE                        COMMAND       CREATED         STATUS         PORTS                    NAMES
    \na46c05bc729b   abichutsky/otus-reddit:1.0   \"/start.sh\"   7 seconds ago   Up 3 seconds   0.0.0.0:9292->9292/tcp   reddit"
}
ok: [84.252.129.18] => {
    "msg": "CONTAINER ID   IMAGE                        COMMAND       CREATED         STATUS         PORTS                    NAMES
    \n07b7b4bf6038   abichutsky/otus-reddit:1.0   \"/start.sh\"   7 seconds ago   Up 3 seconds   0.0.0.0:9292->9292/tcp   reddit"
}

PLAY RECAP *********************************************************************
84.252.129.18              : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
84.252.131.47              : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Проверяем запуск приложения на каждом инстансе по ссылке:   
http://<Публичный IP>:9292 (актуальные ip-адреса для проверки находятся в inventory.ini)


# Домашнее задание №13

* описываем и собираем Docker-образ для сервисного приложения;
* оптимизируем Docker-образы;
* запускаем приложение из собранного Docker-образа;

## Описание

*    Разместил приложение в папку `src`.  Оно разбито на несколько компонентов:

     `post-py` - сервис отвечающий за написание постов;   
     `comment` - сервис отвечающий за написание комментариев;  
     `ui` - веб-интерфейс, работающий с другими сервисами;  

*    Создал Docker-файлы для подготовки образов. Инструкцию `ADD` заменил на `COPY` (рекомендовано).  

     **./post-py/Dockerfile**

     ```
     FROM python:3.6.0-alpine

     WORKDIR /app
     COPY . /app

     RUN apk --no-cache --update add build-base && \
     pip install -r /app/requirements.txt && \
     apk del build-base

     ENV POST_DATABASE_HOST post_db
     ENV POST_DATABASE posts

     ENTRYPOINT ["python3", "post_app.py"]
     ```

     **./comment/Dockerfile**

     ```
     FROM ruby:2.2
     
     RUN apt-get update -qq && apt-get install -y build-essential
     
     ENV APP_HOME /app
     RUN mkdir $APP_HOME
     WORKDIR $APP_HOME

     COPY Gemfile* $APP_HOME/
     RUN bundle install
     COPY . $APP_HOME

     ENV COMMENT_DATABASE_HOST comment_db
     ENV COMMENT_DATABASE comments

     CMD ["puma"]
     ```

     **./ui/Dockerfile (1-й вариант сборки)**

     ```
     FROM ruby:2.2
     RUN apt-get update -qq && apt-get install -y build-essential

     ENV APP_HOME /app
     RUN mkdir $APP_HOME

     WORKDIR $APP_HOME
     ADD Gemfile* $APP_HOME/
     RUN bundle install
     ADD . $APP_HOME

     ENV POST_SERVICE_HOST post
     ENV POST_SERVICE_PORT 5000
     ENV COMMENT_SERVICE_HOST comment
     ENV COMMENT_SERVICE_PORT 9292

     CMD ["puma"]
     ```

*   Подключился к ранее созданному хосту с docker "docker-host" в Yandex Cloud:

     ```
     eval $(docker-machine env docker-host) # переходим в окружение "docker-host"
     docker-machine ls # проверяем, что хост зарегистрирован и активен
     docker rm -f $(docker ps -q) # удалим старые запущенные контейнеры
     ```

*    Собрал образы с нашими сервисами и скачал готовый образ MongoDB (БД используют сервисы `comment` и `post`):

     ```
     docker build -t abichutsky/post:1.0 ./post-py
     docker build -t abichutsky/comment:1.0 ./comment
     docker build -t abichutsky/ui:1.0 ./ui
     docker pull mongo:latest

     # проверяем создание образов
     docker images  
     ```

*    Создал bridge-сеть для контейнеров `reddit`, т.к. сетевые алиасы не работают в дефолтной сети. 
Затем запустил контейнеры.

     ```
     # создаем сеть
     docker network create reddit
     docker network ls # проверяем создание сети

     # запускаем контейнеры с алиасами
     docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
     docker run -d --network=reddit --network-alias=post abichutsky/post:1.0
     docker run -d --network=reddit --network-alias=comment abichutsky/comment:1.0
     docker run -d --network=reddit -p 9292:9292 abichutsky/ui:1.0

     # проверяем запуск контейнеров
     docker ps
     ```

     Проверяем, что приложение доступно по ссылке http://<Публичный IP "docker-host">:9292

*    Затем пересоздал Dockerfile для `ui` с новыми инструкциями:

     **./ui/Dockerfile (2-й вариант сборки)**

     ```
     FROM ubuntu:16.04
     RUN apt-get update \
         && apt-get install -y ruby-full ruby-dev build-essential \
         && gem install bundler --no-ri --no-rdoc

     ENV APP_HOME /app
     RUN mkdir $APP_HOME

     WORKDIR $APP_HOME
     COPY Gemfile* $APP_HOME/
     RUN bundle install
     COPY . $APP_HOME

     ENV POST_SERVICE_HOST post
     ENV POST_SERVICE_PORT 5000
     ENV COMMENT_SERVICE_HOST comment
     ENV COMMENT_SERVICE_PORT 9292

     CMD ["puma"]
     ```

*    Собрал образ `ui:2.0`, запустил новые копии контейнеров c `ui:2.0` вместо `ui:1.0`

     ```
     docker build -t abichutsky/ui:2.0 ./ui 

     docker kill $(docker ps -q) # остановим все запущенные контейнеры 
     docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
     docker run -d --network=reddit --network-alias=post abichutsky/post:1.0
     docker run -d --network=reddit --network-alias=comment abichutsky/comment:1.0
     docker run -d --network=reddit -p 9292:9292 abichutsky/ui:2.0
     ```

     Проверяем, что приложение доступно по ссылке http://<Публичный IP "docker-host">:9292  
     Поскольку контейнер `mongodb` был остановлен и пересоздан, данные приложения не сохранятся.

*    Создал docker volume c именем `reddit_db`,  подключил его к контейнеру с MongoDB, затем запустил новые копии контейнеров:

     ```
     # создать volume
     docker volume create reddit_db
     
     docker kill $(docker ps -q) # остановим все запущенные контейнеры 

     docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
     docker run -d --network=reddit --network-alias=post abichutsky/post:1.0
     docker run -d --network=reddit --network-alias=comment abichutsky/comment:1.0
     docker run -d --network=reddit -p 9292:9292 abichutsky/ui:2.0
     ```

     Проверка: перейдем по ссылке http://<Публичный IP "docker-host">:9292 и добавим пост.  
     После этого пересоздадим все контейнеры. Пост должен остаться, т.к. данные остались на томе.

### Описание инструкций Dockerfile:  

*    
     **Инструкции:**

     `FROM` — задаёт базовый (родительский) образ.
     `LABEL` — описывает метаданные. Например — сведения о том, кто создал и поддерживает образ.  
     `ENV` — устанавливает постоянные переменные среды.  
     `RUN` — выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов.  
     `COPY` — копирует в контейнер файлы и папки (рекомендуется вместо `ADD`).  
     `ADD` — копирует файлы и папки в контейнер, может распаковывать локальные .tar-файлы.  
     `CMD` — описывает команду с аргументами, которую нужно выполнить когда контейнер будет запущен. Аргументы могут быть переопределены при запуске контейнера. В файле может присутствовать лишь одна инструкция CMD.  
     `WORKDIR` — задаёт рабочую директорию для следующей инструкции.  
     `ARG` — задаёт переменные для передачи Docker во время сборки образа.  
     `ENTRYPOINT` — предоставляет команду с аргументами для вызова во время выполнения контейнера. Аргументы не переопределяются.  
     `EXPOSE` — указывает на необходимость открыть порт.  
     `VOLUME` — создаёт точку монтирования для работы с постоянным хранилищем.  

### Задание со *

*    
     **Задание 1**

     - Запустите контейнеры с другими сетевыми алиасами
     - Адреса для взаимодействия контейнеров задаются через ENV-переменные внутри Dockerfile'ов
     - При запуске контейнеров (docker run) задайте им переменные окружения соответствующие новым сетевым алиасам, не пересоздавая образ
     - Проверьте работоспособность сервиса

     Решение

     Добавил ко всем используемым ранее алиасам название `reddit_`.
     При изменении сетевых алиасов мы должны переопределить и ENV-переменные Dockerfile с помощью ключа `--env`, поскольку они отвечают за сетевое взаимодействие контейнеров между собой.

     ```
     docker kill $(docker ps -q) # останавливаем контейнеры

     docker run -d --network=reddit --network-alias=reddit_post_db --network-alias=reddit_comment_db mongo:latest
     docker run -d --network=reddit --network-alias=reddit_post --env POST_DATABASE_HOST=reddit_post_db abichutsky/post:1.0
     docker run -d --network=reddit --network-alias=reddit_comment --env COMMENT_DATABASE_HOST=reddit_comment_db  abichutsky/comment:1.0
     docker run -d --network=reddit -p 9292:9292 --env POST_SERVICE_HOST=reddit_post --env COMMENT_SERVICE_HOST=reddit_comment abichutsky/ui:1.0
     ```
*
     **Задание 2**

     - Соберите образ на основе Alpine Linux
     - Придумайте еще способы уменьшить размер образа

     Решение

     Создал Dockerfile.1 для сервиса `ui`.
     Оптимизация размера образа выполняется за cчет опции установки пакетов `--no-cache` и удаления кэша `rm -rf /var/cache/apk/*` (если что-то осталось).

     ```
     FROM alpine:3.12.4

     LABEL Name="Reddit App UI for Alpine"
     LABEL Version="1.0"

     RUN apk --update add --no-cache \
         ruby-full \
         ruby-dev \
         build-base \
         && gem install bundler:1.17.2 --no-document \
         && rm -rf /var/cache/apk/*

     ENV APP_HOME /app
     RUN mkdir $APP_HOME

     WORKDIR $APP_HOME
     COPY Gemfile* $APP_HOME/
     RUN bundle install
     COPY . $APP_HOME

     ENV POST_SERVICE_HOST post
     ENV POST_SERVICE_PORT 5000
     ENV COMMENT_SERVICE_HOST comment
     ENV COMMENT_SERVICE_PORT 9292

     CMD ["puma"]
     ```

     Создать образ `alpine_ui:1.0` и запустить копии контейнеров, включая `alpine_ui:1.0`:

     ```
     docker build -f ./ui/Dockerfile.1 -t abichutsky/alpine_ui:1.0 ./ui
     
     docker kill $(docker ps -q) # останавливаем контейнеры
     
     docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
     docker run -d --network=reddit --network-alias=post abichutsky/post:1.0
     docker run -d --network=reddit --network-alias=comment abichutsky/comment:1.0
     docker run -d --network=reddit -p 9292:9292 abichutsky/alpine_ui:1.0
     ```
     
     Проверка
     
     ```
     $ docker images
     REPOSITORY               TAG            IMAGE ID       CREATED        SIZE
     abichutsky/alpine_ui     1.0            85612b6d9145   17 hours ago   275MB
     abichutsky/ui            2.0            1457935b9695   20 hours ago   458MB
     abichutsky/ui            1.0            85e79518e52c   20 hours ago   771MB
     abichutsky/comment       1.0            35876ffbb375   22 hours ago   768MB
     abichutsky/post          1.0            ee1a47582346   22 hours ago   110MB
     ...
     ```
     
     ```
     $ docker ps
     CONTAINER ID   IMAGE                      COMMAND                  CREATED        STATUS        PORTS                    NAMES
     5af697ade0dd   abichutsky/alpine_ui:1.0   "puma"                   17 hours ago   Up 17 hours   0.0.0.0:9292->9292/tcp  nifty_mclean
     083917c3ae58   abichutsky/comment:1.0     "puma"                   17 hours ago   Up 17 hours                            hopeful_darwin
     b3769845c1ea   abichutsky/post:1.0        "python3 post_app.py"    17 hours ago   Up 17 hours                            quizzical_maxwell
     ea211f9b0e8c   mongo:latest               "docker-entrypoint.s…"   17 hours ago   Up 17 hours   27017/tcp                infallible_chatelet
     ```

     Проверяем, что приложение доступно по ссылке: http://<Публичный IP "docker-host">:9292  
     В моем случае: http://84.252.129.111:9292
