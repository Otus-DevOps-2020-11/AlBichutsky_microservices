# AlBichutsky_microservices
AlBichutsky microservices repository

### Домашнее задание №12

Установил последние версии `docker`, `docker-compose`, `docker-machine`:

```bash     
# Подробнее:
# https://docs.docker.com/engine/install/centos/

Установка `docker`

```bash
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

Установка `docker-compose`

```bash
yum install -y docker-compose
docker-compose version
```

Установка docker-machine

```bash
# бинарник кладем в /usr/bin или /usr/local/bin/
curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && 
chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/bin/docker-machine
```

Команды docker:

```bash
# Получение информации о контейнерах и образах:

docker images  # посмотреть список сохраненных образов
docker images -a  # посмотреть список сохраненных образов, включая промежуточныe
docker images -q   # посмотреть id всех образов

docker ps      # посмотреть список запущенных контейнеров
docker ps -a   # посмотреть список всех контейнеров (включая остановленные)
docker ps -q   # посмотреть id всех контейнеров

docker inspect <image>  # получить параметры образа в JSON-формате
docker inspect <container>  # получить параметры контейнера в JSON-формате
docker inspect <container> -f '{{.ContainerConfig.Cmd}}' # получить значение конкретного параметра контейнера

docker system df  # посмотреть информацию, сколько дискового пространства занято образами, контейнерами, томами и сколько можно удалить

docker logs <container> -f  # посмотреть логи контейнера

docker diff <container>  # посмотреть изменения в файловой системе docker
```

```bash
# Запуск контейнеров:

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

docker exec -it <container> bash # запустить новый процесс bash внутри контейнера
root@<u_container_id>
```

```bash
# Остановка и удаление контейнеров:

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

- Загрузил образ `reddit:latest` в docker-hub с названием `otus-reddit:1.0`:

```bash
docker login  # аутентируемся в docker-hub
docker tag reddit:latest abichutsky/otus-reddit:1.0
docker push abichutsky/otus-reddit:1.0
```

- Затем запустил контейнер из образа в локальном окружении docker:

```bash
# переходим в отдельную консоль
eval $(docker-machine env --unset) # переключимся c удаленного окружения docker в локальное
docker ps -a  # убедимся, что мы в нужном окружении
docker run --name reddit -d -p 9292:9292 abichutsky/otus-reddit:1.0 # запускаем контейнер
```
Приложение должно быть доступно по адресу: http://localhost:9292


