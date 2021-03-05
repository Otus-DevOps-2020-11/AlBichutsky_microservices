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
# Получить сведения о контейнерах и образах

docker images  # Вывести список сохраненных образов
docker ps      # Вывести список запущенных контейнеров
docker ps -a   # Вывести список всех контейнеров
docker inspect <u_image_id>  # получить подробную информацию об образе в JSON-формате
docker inspect <u_container_id>  # получить подробную информацию о контнйнере в JSON-формате
docker system df  # вывести информацию, сколько дискового пространства занято образами, контейнерами м томами

# Запуск контейнеров

# docker run = docker create + docker start + docker attach при наличии опции -i  (каждый раз запускается новый контейнер)
# -i – запускает контейнер в foreground режиме ( docker attach )
# -d – запускает контейнер в background режиме
# -t создает TTY

docker run -it ubuntu:18.04 /bin/bash # запустить контейнер с TTY в foreground режиме
root@<u_container_id>:/# echo 'Hello world!' > /tmp/file
root@<u_container_id>:/# exit  # после выхода контейнер останется на диске

docker run -it -rm ubuntu:18.04 /bin/bash  # чтобы контейнер удалялся после выхода указываем -rm

docker run -dt ubuntu:18.04  # запустить контейнер с TTY в background режиме

docker start <u_container_id>  # запустить остановленный (уже созданный) контейнер

docker attach <u_container_id> # присоеденить терминал к созданному контейнеру
root@<u_container_id>:/# cat /tmp/file
Hello world!

docker exec -it <u_container_id> bash # запустить новый процесс bash внутри контейнера

# Остановка и удаление контейнеров

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
Приложение должно быть доступно по адресу: http://localhost:9292"

