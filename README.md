# AlBichutsky_microservices
AlBichutsky microservices repository

# Домашнее задание №12
## Технология контейнеризации. Введение в Docker.

- Создание docker-host  
- Создание своего образа
- Работа с Docker Hub

### Описание

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
# -t, --tty – предоставить терминал
# --name – присвоить имя контейнеру
# --rm – удалить контейнер после выхода из него

docker run -it <image> /bin/bash # запустить контейнер и выполнить bash в терминале в foreground режиме
root@<container_id>:/# echo 'Hello world!' > /tmp/file
root@<container_id>:/# exit

docker run -it -rm <image> /bin/bash # запустить контейнер и выполнить bash в терминале в foreground режиме, после выхода контейнер будет удален

docker run -dt <image> # запустить контейнер в background режиме

# Работа с остановленным контейнером
docker start <container> # запустить остановленный (уже созданный) контейнер
docker attach <container> # присоеденить к нему терминал
root@<u_container_id>:/# cat /tmp/file
Hello world!

docker exec -it <container> bash # запустить новый процесс bash внутри контейнера
root@<u_container_id>
```

#### Остановка и удаление контейнеров

```bash
docker stop <container1>  # остановить контейнер

docker kill $(docker ps -q)  # Остановить работающие контейнеры (послать SIGKILL)

docker rm <container1> <container2> # удалить незапущенные контейнеры
docker rm -f <container1> <container2> # удалить запущенные контейнеры
docker rm $(docker ps -a -q) # удалить все незапущенные контейнеры
dpcker rm -f $(docker ps -q) # удалить все запущенные контейнеры

docker rmi <image1> <image2> # удалить образы (не будут удалены, если есть запущенные контейнеры)
docker rmi -f <image> # удалить образ, даже если контейнер запущен
docker rmi $(docker images -q) # удалить все сохраненные образы

docker prune # удалить неиспользуемые данные, см. docker system df
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
`docker-machine` - встроенный в докер инструмент для создания хостов и установки на них
docker engine.

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
docker-machine create ...  # создать или проинициализировать docker-хост

docker-machine ls  # показать список проинициализированных и активных docker-хостов
NAME          ACTIVE   DRIVER    STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        generic   Running   tcp://84.252.129.111:2376           v20.10.5   

docker-machine <имя машины> status  # проверить состояние docker-хоста
docker-machine ssh <имя машины> # подключиться по ssh
docker-machine <имя машины> rm  # удалить docker-хост

eval $(docker-machineenv --unset) # переключиться на локальный docker
eval $(docker-machine env <имя машины>)  # переключиться к окружению docker-хоста <имя машины>
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
eval $(docker-machine env --unset) # переключиться на локальный docker
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

**Решение**

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
## Docker-образы. Микросервисы.

* описываем и собираем Docker-образ для сервисного приложения;
* оптимизируем Docker-образы;
* запускаем приложение из собранного Docker-образа;

## Описание

*    Скопировал файлы приложения в папку `src`.  Оно разбито на несколько компонентов:

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
     Поскольку контейнер с `mongodb` был остановлен и пересоздан, комментарии не сохранились.

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
     После этого перезапустим копии контейнеров. Посты приложения будут сохранены, т.к. данные БД хранятся на томе.

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

     
# Домашнее задание №14  
## Docker: сети, docker-compose

- Работа с сетями в Docker
- Использование docker-compose

### Описание

- Подключился к окружению удаленного docker-хоста:

```bash
eval $(docker-machine env docker-host) # переходим в окружение docker-хоста "docker-host" в Yandex Cloud
docker-machine ls # проверяем, что хост зарегистрирован и активен
# далее можем использовать docker CLI для управления хостом со своей локальной машины, например
docker ps
```

Подключиться к удаленному docker-хосту по ssh:

```bash
docker-machine ssh docker-host # актуально для выполнения комманд на самом хосте
# что аналогично
ssh -i ~/.ssh/id_rsa yc-user@84.252.129.111
```

- Запустил контейнеры с использованием драйверов сети:
   - `none`
   - `host`
   - `bridge`
  
 При запуске используется ключ: `--network <none>, <host>, <bridge>`

Для проверок используется образ `joffotron/docker-net-tools` с сетевыми утилитами.

### None netwok driver

Внутри контейнера из сетевых интерфейсов существует только loopback. Сетевой стек работает для localhost без возможности контактировать с внешним миром. Подходит для запуска сетевых сервисов внутри контейнера для локальных экспериментов.

Проверка:

```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

### Host netwok driver

Контейнер использует network namespace (пространство имен) docker-хоста.  
Сетевые интерфейсы хоста и контейнера одинаковые.

Проверил сетевые интерфейсы на докер-хосте: 

```
docker-machine ssh docker-host ifconfig
``` 

Сравнил интерфейсы в контейнере - они идентичны:

```bash
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig

br-251a47bf0c24 Link encap:Ethernet  HWaddr 02:42:F0:3D:CB:FE  
          inet addr:172.18.0.1  Bcast:172.18.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:f0ff:fe3d:cbfe%32739/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:788 errors:0 dropped:0 overruns:0 frame:0
          TX packets:855 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:286436 (279.7 KiB)  TX bytes:241568 (235.9 KiB)

docker0   Link encap:Ethernet  HWaddr 02:42:67:4B:5A:4C  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:67ff:fe4b:5a4c%32739/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:82927 errors:0 dropped:0 overruns:0 frame:0
          TX packets:112318 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:5437907 (5.1 MiB)  TX bytes:1008029212 (961.3 MiB)

eth0      Link encap:Ethernet  HWaddr D0:0D:F6:A5:A4:A4  
          inet addr:10.130.0.32  Bcast:10.130.0.255  Mask:255.255.255.0
          inet6 addr: fe80::d20d:f6ff:fea5:a4a4%32739/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:618985 errors:0 dropped:0 overruns:0 frame:0
          TX packets:458968 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1876066979 (1.7 GiB)  TX bytes:280541025 (267.5 MiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32739/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:552706 errors:0 dropped:0 overruns:0 frame:0
          TX packets:552706 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:82583417 (78.7 MiB)  TX bytes:82583417 (78.7 MiB)

veth1ff5366 Link encap:Ethernet  HWaddr 06:80:1A:89:93:37  
          inet6 addr: fe80::480:1aff:fe89:9337%32739/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:472615 errors:0 dropped:0 overruns:0 frame:0
          TX packets:465944 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:55470171 (52.9 MiB)  TX bytes:47420470 (45.2 MiB)

veth5c64a56 Link encap:Ethernet  HWaddr 5E:F4:AD:75:65:B1  
          inet6 addr: fe80::5cf4:adff:fe75:65b1%32739/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:999695 errors:0 dropped:0 overruns:0 frame:0
          TX packets:779614 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:105733292 (100.8 MiB)  TX bytes:124010511 (118.2 MiB)

veth61704a7 Link encap:Ethernet  HWaddr 76:A1:D4:C8:60:51  
          inet6 addr: fe80::74a1:d4ff:fec8:6051%32739/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1091955 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1648357 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:200920771 (191.6 MiB)  TX bytes:177867928 (169.6 MiB)

vethf47f7f6 Link encap:Ethernet  HWaddr FE:0A:5E:A4:02:CF  
          inet6 addr: fe80::fc0a:5eff:fea4:2cf%32739/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1114067 errors:0 dropped:0 overruns:0 frame:0
          TX packets:784783 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:119475920 (113.9 MiB)  TX bytes:132302216 (126.1 MiB)
```

### Network namespaces

Network namespaces (простанство имен сетей) обеспечивает изоляюцию сетей в контейнерах.  
Проверил создание network namespaces на docker-хосте:

```bash
# Подключился к docker-хосту
docker-machine ssh docker-host

# создал симлинк
sudo ln -s /var/run/docker/netns /var/run/netns

# запустил контейнер в сети none
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig

# Проверил network namespaces:
sudo ip netns
# в сети "none" создается свой net-namespace (даже для loopback-интерфейса)
Error: Peer netns reference is invalid.
Error: Peer netns reference is invalid.
cd4afab32317
default

# запустил контейнер в сети "host"
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
# Проверил network namespaces:
sudo ip netns
# в сети host net-namespace не создается (есть только default)
default
```

Попробовал запустить несколько контейнеров с `nginx` в сети `host`:

```bash
# Запустил контейнер c nginx
docker run --network host -d nginx  # 4 раза

# проверил запуск
docker ps

CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
6950cc487582   nginx     "/docker-entrypoint.…"   58 seconds ago   Up 57 seconds             distracted_bell

# Вывод: запущен только один контейнер, остальные были остановлены. 
# Это связано с тем, что сеть в запускаемых контейнерах, использующих host-драйвер не изолирована. 
# Несколько контейнеров c nginx не могут делить одну хостовую сеть (может работать 1 контейнер).   
```

### Bridge network driver

- Контейнеры могут взаимодействовать между собой (если они в одной подсети)
- Выходят в интернет через NAT (через интерфейс хоста).
- По-умолчанию создается сеть `default-bridge`, но она менее функциональна (лучше использовать обычную `bridge`).

Команды:

```bash
# Создать сеть с brige-драйвером
docker network create <network_name> --driver bridge

# Чтобы контейнеры могли общаться между собой по DNS-именам, указанным в ENV-переменных, назначаем им имена и алиасы:
# --name <name_container>  - присовить имя (при иницализации контейнера можно задать только 1 имя) 
# --network-alias <alias_name>  - присвоить алиас (можно задать множество множество)

# Создать docker-сети
docker network create <network_name> --subnet=NETWORK1/MASK # пример: --subnet=10.0.2.0/24
docker network create <network_name> --subnet=NETWORK2/MASK # пример: --subnet=10.0.1.0/24

# Запустить контейнер с назначением имени
docker run -d --network=<network_name> -p <port>:<port> --name <container_name> <image> 
docker run -d --network=<network_name> --name <container_name> <image>

# Запустить контейнер с назначением имени и алиасов
docker run -d --network=back_net --name <container_name> --network-alias=<name_alias1> --network-alias=<name_alias2> <image>

# Подключить контейнер к сети
docker network connect <network_name> <сontainer_name>

# Посмотреть сети docker
docker network ls
```

- Запустил контейнеры и подключил их к подсетям:

```bash
docker kill $(docker ps -q)

# Создадим 2 docker-сети
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

# Запустим контейнеры с алиасами в 
docker run -d --network=front_net -p 9292:9292 --name ui  <your-dockerhub-login>/ui:1.0
docker run -d --network=back_net --name comment  <your-dockerhub-login>/comment:1.0
docker run -d --network=back_net --name post  <your-dockerhub-login>/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest

# Подключим контейнеры post и comment также к сети front_net
docker network connect front_net post
docker network connect front_net comment
```

- Исследовал bridge-сеть:

```bash
# Подключился к docker-хосту
docker-machine ssh docker-host
sudo apt-get update && sudo apt-get install bridge-utils

# Проверил bridge-интерфейсы
sudo docker network ls
sudo ifconfig | grep br
br-251a47bf0c24: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 172.18.255.255
br-3e91715a392f: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.19.0.1  netmask 255.255.0.0  broadcast 172.19.255.255
br-410cdf95a2db: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 10.0.2.1  netmask 255.255.255.0  broadcast 10.0.2.255
br-d59b8c806e7d: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 10.0.1.1  netmask 255.255.255.0  broadcast 10.0.1.255
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet 10.130.0.32  netmask 255.255.255.0  broadcast 10.130.0.255

# Проверил veth-интерфейсы - это те части виртуальных пар интерфейсов, которые лежат в сетевом пространстве хоста и также отображаются в ifconfig. 
# Вторые их части лежат внутри контейнеров.
brctl show br-410cdf95a2db

bridge name     bridge id               STP enabled     interfaces
br-410cdf95a2db         8000.02423511218b       no

# Проверил использование NAT контейнерами в iptables:
sudo iptables -nL -t nat 

...
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  172.19.0.0/16        0.0.0.0/0           
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0           
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0           
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0           
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0           
MASQUERADE  tcp  --  172.19.0.3           172.19.0.3           tcp dpt:9292
...

# Здесь же видим правило DNAT, отвечающее за перенаправление трафика на адреса конкретных контейнеров
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:172.19.0.3:9292

# Проверим, что docker-proxy слушает tcp-порт 9292
ps ax | grep docker-proxy
 1771 pts/1    R+     0:00 grep --color=auto docker-proxy
30670 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 172.19.0.3 -container-port 9292
```

### docker-compose

- Установил последнюю версию `docker-compose`:

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /bin/docker-compose
chmod +x /bin/docker-compose
```

- Описал в `docker-compose.yml` сборку контейнеров с сетями, алиасами (параметризировал с помощью переменных окружений):

docker-compose.yml

```yml
version: '3.3'

services:
  
  post_db:
    env_file: .env
    image: mongo:${MONGODB_VERSION}
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db

  ui:
    env_file: .env
    build: ./ui
    image: ${USERNAME}/ui:${UI_VERSION}
    ports:
      - ${UI_HOST_PORT}:${UI_CONTAINER_PORT}/tcp
    networks:
      - front_net

  post:
    env_file: .env
    build: ./post-py
    image: ${USERNAME}/post:${POST_VERSION}
    networks:
      - front_net
      - back_net

  comment:
    env_file: .env
    build: ./comment
    image: ${USERNAME}/comment:${COMMENT_VERSION}
    networks:
      - front_net
      - back_net

volumes:
  post_db:

networks:

  front_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${FRONT_NET_SUBNET}
  
  back_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${BACK_NET_SUBNET}
```

В файле .env хранятся значения переменных (вызывается при запуске docker-compose):

```
# порт публикации приложения
UI_HOST_PORT=9292
UI_CONTAINER_PORT=9292

# логин (часть имени репозитория образа)
USERNAME=alex

# версии образов
MONGODB_VERSION=3.2
UI_VERSION=1.0
POST_VERSION=1.0
COMMENT_VERSION=1.0

# подсети
FRONT_NET_SUBNET=10.0.1.0/24
BACK_NET_SUBNET=10.0.2.0/24
```

Запустить приложение:

```
docker kill $(docker ps -q) # остановим старые контейнеры docker
docker-compose up -d
```

Проверка:

```
docker-compose ps

    Name                  Command             State           Ports         
----------------------------------------------------------------------------
src_comment_1   puma                          Up                            
src_post_1      python3 post_app.py           Up                            
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp             
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```

Альтернативный способ запуска:   
используем ключ `--env-file` с указанием пути к файлу .env:

```bash
# удалим из docker-compose.yml строчки "env_file: .env"
docker-compose --env-file .env up -d
```
Подробнее: https://docs.docker.com/compose/environment-variables

Приложение доступно по адресу: http://84.252.129.111:9292

**Изменение базового имени проекта**

По-умолчанию имя проекта (префикс) создается из имени каталога, в котором находится проект
(в нашем случае `src`). Его можно задать одним из способов:

1) Добавить в файл .env переменную:

```
COMPOSE_PROJECT_NAME=reddit
```

2) Использовать при запуске ключ ` -p, --project-name NAME`, пример:

```
docker-compose --project-name reddit up -d
```

Подробнее: https://docs.docker.com/compose/reference/envvars/


### Задание со *

Создайте docker-compose.override.yml для reddit проекта, который позволит:  
• Изменять код каждого из приложений, не выполняя сборку образа;  
• Запускать puma для ruby приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2).  

**Решение**

Docker Compose по умолчанию по-очереди читает два файла: `docker-compose.yml` и `docker-compose.override.yml`.  
В последнем можно хранить переопределения для существующих сервисов или определять новые.

docker-compose.override.yml

```
version: '3.3'
services:

  ui:
    env_file: .env
    volumes:
      - ./ui:/app
    command: ["puma", "--debug", "-w", "2"]

  post:
    env_file: .env
    volumes:
      - ./post-py:/app
      
  comment:
    env_file: .env
    volumes:
      - ./comment:/app
    command: ["puma", "--debug", "-w", "2"]
```

Задан `bind mount`:  
- <путь к каталогу приложения на локальном хосте (папка с исходниками проекта)>:<путь к каталогу приложения в контейнере>

Поскольку монтируются папки локального хоста, проверим приложение локально.   
Иначе придется копировать файлы проекта на удаленный docker-хост. 

Проверяем, что воркеры запущены:

```bash
eval $(docker-machine env --unset) # переключиться на локальный docker
docker-machine ls
docker-compose down # остановить и удалить контейнеры
docker-compose up -d # запустить контейнеры
docker-compose config # проверить конфиг
docker-compose ps
   Name                  Command             State           Ports         
----------------------------------------------------------------------------
src_comment_1   puma --debug -w 2             Up                            
src_post_1      python3 post_app.py           Up                            
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp             
src_ui_1        puma --debug -w 2             Up      0.0.0.0:9292->9292/tcp
```

Проверяем, что можем изменять файлы проекта, не производя билд образа.  
На локальном хосте:

```bash
cd src/ui # переходим в каталог приложения ui
touch newfile.txt # создадим новый файл
ls
config.ru        Dockerfile    Gemfile       helpers.rb     newfile.txt  VERSION
docker_build.sh  Dockerfile.1  Gemfile.lock  middleware.rb  ui_app.rb    views
```

Проверяем, что файл отображается в папке приложения в контейнере:

```
docker-compose exec ui ls ../app
Dockerfile    Gemfile.lock  docker_build.sh  newfile.txt
Dockerfile.1  VERSION       helpers.rb       ui_app.rb
Gemfile       config.ru     middleware.rb    views
```

Приложение доступно по адресу: http://localhost:9292

# Домашнее задание №15
## Устройство GitLab CI. Построение процесса непрерывной поставки.

### Установка GitLab CI

- Создал инстанс для `gitlab` через Web-консоль Yandex Cloud.

- Проинициализировал на нем docker через `docker-machine`:

```bash
docker-machine create \
  --driver generic \
  --generic-ip-address=84.252.129.137 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  gitlab-ci-vm
```

- На инстансе создал необходимые каталоги:

```bash
docker-machine env gitlab-ci-vm
eval $(docker-machine env gitlab-ci-vm)
docker-machine ssh gitlab-ci-vm # подключаемся по ssh со своего хоста к инстансу
mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
```

- Запустил `gitlab` через `docker-compose`:

```bash
cd /srv/gitlab
touch docker-compose.yml
docker-compose up -d
```

docker-compose.yml

```yml
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://<YOUR-VM-IP>'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

- Для выполнения push с локального хоста в gitlab добавил remote:

```bash
git remote add gitlab http://84.252.129.137/homework/example.git
git push gitlab gitlab-ci-1
```

### Создание раннеров

- Добавил раннер на инстансе:

```
docker run -d --name gitlab-runner --restart always -v /srv/gitlabrunner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
```

- Затем зарегистрировал его:

``` bash
docker exec -it gitlab-runner gitlab-runner register \
 --url http://84.252.129.137/ \
 --non-interactive \
 --locked=false \
 --name DockerRunner \
 --executor docker \
 --docker-image alpine:latest \
 --registration-token HdwZqxXcFHcobLsnVSQE \
 --tag-list "linux,xenial,ubuntu,docker" \
 --run-untagged
```

### Тесты в пайплайне

- Добавил исходники приложения `reddit` в локальный репозиторий:

```bash
cd reddit
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
```

- Добавил файл `simpletest.rb` с тестами в каталог `reddit`: 

```ruby
require_relative './app'
require 'test/unit'
require 'rack/test'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_request
    get '/'
    assert last_response.ok?
  end
end
```

- Добавил библиотеку `rack-test` для тестирования в reddit/Gemfile:

```ruby
...
gem 'rack-test'
...
```

- Файл пайплайна `.gitlab-ci.yml` (необходимо запушить):
  - этапы в `stage` выполняются последовательно; 
  - задания `staging` и `production` запускаются вручную (опция `when`);

```yaml
image: ruby:2.4.2

stages:
  - build
  - test
  - review
  - stage
  - production

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'
   
before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com

branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master

staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: http://beta.example.com

production:
  stage: production
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: http://example.com
```

Запушил файлы проекта и пайплайна `.gitlab-ci.yml` в репозиторий gitlab:

```bash
git add ...
git commit -m ...
git push gitlab gitlab-ci-1
```

### Проверка запуска пайплайна

Инстанс с `Gitlab CI` доступен по ссылке http://84.252.129.137

- Изменения без указания тэга запустят пайплайн без задач `staging` и `production`.
- Изменение, помеченное тэгом в git, запустит полный пайплайн (`staging` и `production` запускаются вручную).
- на каждую ветку в git, отличную от master, Gitlab CI будет определять новое окружение.


На локальном хосте закоммитим файлы, укажем тэг (версию) и запушим в gitlab:

```
git add ...
git commit -am 'test ver 2.4.22'
git tag 2.4.22
git push gitlab gitlab-ci-1 --tags
```

Проверка:

[Запуск пайплайна](gitlab-ci/gitlab1.png)  
[Создание окружений](gitlab-ci/gitlab2.png)


# Домашнее задание №16
## Введение в мониторинг. Системы мониторинга.

- Prometheus: запуск, конфигурация, Web UI
- Мониторинг состояния микросервисов
- Сбор метрик хоста с использованием экспортера

### Подготовка

- Создал инcтсанс в Yandex Cloud, проинициализировал на нем docker: 

```bash
yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub
	
docker-machine create \
  --driver generic \
  --generic-ip-address=178.154.201.80 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  docker-host

# перейти в окружение docker хоста  
eval $(docker-machine env docker-host)
```

- Дополнительно установил `docker-compose` на docker хосте:

```
docker-machine ssh docker-host
sudo apt install docker-compose
```

- Запустил `Prometheus` в контейнере для проверки:

```bash
docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus
```

- Переупорядчил структуру директорий:
  - Создал каталог `./docker` и перенес в него каталог
`docker-monolith` и файлы `docker-compose.*`, `.env` (переименовал `.env.example`).  
  В нем будем запускать микросервисы в `docker-compose`.
  - создал каталог `./monitoring/prometheus` c файлами: `Dockerfile`, `prometheus.yml`.  
    В нем будем собирать образ `Prometheus`.

### Сборка образов

- Собрал образы микросервисов с healthckeck-ми:

Сборка сервисов `reddit` с помощью скриптов:

```bash
export USER_NAME=abichutsky # добавляем префикс для образа

/src/ui      $ bash docker_build.sh
/src/post-py $ bash docker_build.sh
/src/comment $ bash docker_build.sh
```

Сборка `Prometheus` из Dockerfile:

```bash
cd ./monitoring/prometheus
docker build -t $USER_NAME/prometheus .
```

Dockerfile

```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```

конфиг `prometheus.yml` - настраиваем сбор метрик с: 
  - prometheus, ui, comment
  - node-exporter - транислирует метрики с самого docker-хоста (инстанса) в качестве агента

```yml
---
    global:
      scrape_interval: '5s'
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets:
            - 'localhost:9090'
    
      - job_name: 'ui'
        static_configs:
          - targets:
            - 'ui:9292'
    
      - job_name: 'comment'
        static_configs:
          - targets:
            - 'comment:9292'
      
      - job_name: 'node'
        static_configs: 
          - targets: 
            - 'node-exporter:9100'
```

### Запуск микросервисов

- Описал запуск микросервисов в docker-compose.yml:

```yml
version: '3.3'
services:

  prometheus:
    image: ${USER_NAME}/prometheus
    ports:
      - 9090:9090
    volumes:
      - prometheus_data:/prometheus
    command:
    # Передаем доп параметры вкомандной строке
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d' # Задаем время хранения метрик в 1 день
    networks:
      - front_net
      - back_net    
  
  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'  
    networks:
      - front_net
      - back_net  

  post_db:
    env_file: .env
    image: mongo:${MONGODB_VERSION}
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db

  ui:
    env_file: .env
#    build: ./ui
#    image: ${USER_NAME}/ui:${UI_VERSION}
    image: ${USER_NAME}/ui
    ports:
      - ${UI_HOST_PORT}:${UI_CONTAINER_PORT}/tcp
    networks:
      - front_net

  post:
    env_file: .env
#    build: ./post-py
#    image: ${USER_NAME}/post:${POST_VERSION}
    image: ${USER_NAME}/post
    networks:
      - front_net
      - back_net
      
  comment:
    env_file: .env
#    build: ./comment
#    image: ${USER_NAME}/comment:${COMMENT_VERSION}
    image: ${USER_NAME}/comment
    networks:
      - front_net
      - back_net

volumes:

  post_db: 
  prometheus_data:

networks:

  front_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${FRONT_NET_SUBNET}
  
  back_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${BACK_NET_SUBNET}
```

- Запустил микросервисы (поднимаются сервисы reddit + prometheus + node exporter):

```bash
# игнорируем docker-compose.override.yml при запуске
docker-compose -f docker-compose.yml up -d
docker-compose ps

         Name                       Command               State           Ports         
----------------------------------------------------------------------------------------
docker_comment_1         puma                             Up                            
docker_node-exporter_1   /bin/node_exporter --path. ...   Up      9100/tcp              
docker_post_1            python3 post_app.py              Up                            
docker_post_db_1         docker-entrypoint.sh mongod      Up      27017/tcp             
docker_prometheus_1      /bin/prometheus --config.f ...   Up      0.0.0.0:9090->9090/tcp
docker_ui_1              puma   
```

- Запушил образы в свой репозиторий docker-hub: 

```
docker login
docker push $USER_NAME/ui
docker push $USER_NAME/comment
docker push $USER_NAME/post 
docker push $USER_NAME/prometheus
```

### Проверка

1) Образы загружены в docker-hub: https://hub.docker.com/u/abichutsky
2) Prometheus доступен по ссылке: http://178.154.201.80:9090
3) Проверка мониторинга:

[Targets, за которыми следит Prometheus](monitoring/prometheus/prometh-targets.png)  
[health check основного сервиса ui](monitoring/prometheus/prometh_ui_health.png)  
[health check зависимого сервиса comment](monitoring/prometheus/prometh_ui_health_comments_avail.png)   
[Информация об использ. CPU docker-хоста (сбор идет через node exporter)](monitoring/prometheus/prometh_node_load.png)


# Домашнее задание №17
## Мониторинг приложения и инфраструктуры

- Мониторинг Docker контейнеров
- Визуализация метрик
- Сбор метрик работы приложения и бизнес метрик
- Настройка и проверка алертинга

### Описание

- Собрал docker-образы `prometheus` и `alertmanager`

- Подготовил `docker-compose` файлы:

  - docker-compose.yml для запуска приложения reddit:

```yml
version: '3.3'
services:

  post_db:
    env_file: .env
    image: mongo:${MONGODB_VERSION}
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db

  ui:
    env_file: .env
#    build: ./ui
#    image: ${USER_NAME}/ui:${UI_VERSION}
    image: ${USER_NAME}/ui
    ports:
      - ${UI_HOST_PORT}:${UI_CONTAINER_PORT}/tcp
    networks:
      - front_net

  post:
    env_file: .env
#    build: ./post-py
#    image: ${USER_NAME}/post:${POST_VERSION}
    image: ${USER_NAME}/post
    networks:
      - front_net
      - back_net
      
  comment:
    env_file: .env
#    build: ./comment
#    image: ${USER_NAME}/comment:${COMMENT_VERSION}
    image: ${USER_NAME}/comment
    networks:
      - front_net
      - back_net

volumes:
  post_db: 

networks:
  front_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${FRONT_NET_SUBNET}
  back_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${BACK_NET_SUBNET}
```

  - docker-compose-monitoring.yml для запуска приложений мониторинга:

```yml
version: '3.3'
services:

    prometheus:
        env_file: .env
        image: ${USER_NAME}/prometheus
        ports:
            - 9090:9090
        volumes:
            - prometheus_data:/prometheus
        command:
        # Передаем доп параметры вкомандной строке
            - '--config.file=/etc/prometheus/prometheus.yml'
            - '--storage.tsdb.path=/prometheus'
            - '--storage.tsdb.retention=1d' # Задаем время хранения метрик в 1 день
        networks:
            - front_net
            - back_net    
    
    node-exporter:
        image: prom/node-exporter:v0.15.2
        user: root
        volumes:
        - /proc:/host/proc:ro
        - /sys:/host/sys:ro
        - /:/rootfs:ro
        command:
        - '--path.procfs=/host/proc'
        - '--path.sysfs=/host/sys'
        - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'  
        networks:
        - front_net
        - back_net  

    cadvisor:
        image: google/cadvisor:v0.29.0
        volumes:
            - '/:/rootfs:ro'
            - '/var/run:/var/run:rw'
            - '/sys:/sys:ro'
            - '/var/lib/docker/:/var/lib/docker:ro'
        ports:
            - '8080:8080'
        networks:
            - front_net

    grafana:
        image: grafana/grafana:5.0.0
        volumes:
            - grafana_data:/var/lib/grafana
        environment:
            - GF_SECURITY_ADMIN_USER=admin
            - GF_SECURITY_ADMIN_PASSWORD=secret
        depends_on:
            - prometheus
        ports:
            - 3000:3000
        networks:
            - front_net
            - back_net

    alertmanager:
        env_file: .env
        image: ${USER_NAME}/alertmanager
        command: 
            - '--config.file=/etc/alertmanager/config.yml'
        ports: 
            - 9093:9093
        networks:
            - front_net

volumes:
    prometheus_data:
    grafana_data:
        
networks:    
    front_net:
        driver: bridge
        ipam:
            driver: default
            config:
                - subnet: ${FRONT_NET_SUBNET}   
    back_net:
        driver: bridge
        ipam:
            driver: default
            config:
                - subnet: ${BACK_NET_SUBNET}
```

Приложения мониторинга включают в себя:  
prometheus (сбор метрик)  
node-exporter  
cAdvisor (собирает метрики контейнеров и хоста и публикует их для prometheus)  
grafana (визуализация метрик prometheus)  
alertmanager (доп.компонент для Prometheus, отправляет алерты в slack)


- Экспортировал настроенные дашборды grafana в .json в каталог grafana/dashboards

- Запушил собранные образы в DockerHub


### Запуск и проверка

```bash
# запускаем приложение
docker-compose -f docker-compose.yml up -d
# запускаем мониторинг
docker-compose -f docker-compose-monitoring.yml up -d
```

Проверяем, что алерты отправляются в slack:

```
docker-compose stop post
```

Инстанс доступен по адресу: http://178.154.201.80

