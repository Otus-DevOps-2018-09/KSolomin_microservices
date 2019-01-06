# KSolomin_microservices
KSolomin microservices repository

Домашнее задание 16:

Задания с "*":

1. Слак с Гитлабом сынтегрирован, можно проверить по ссылке:
https://devops-team-otus.slack.com/messages/CDB4NHWN8/details/

2. 

Домашнее задание 15:

Ответы на вопросы:
1. Если запускать "docker run --network host -d nginx" несколько раз, контейнер поднимется только единожды. Это происходит, потому что первый запуск резервирует 80-ый порт хостовой машины, другие контйнеры уже не смогут на нем работать. 

2. При запуске контейнера с network none теперь видим что создается новый network namespace:

docker run -d --network none nginx
12d5114418636d1183795f90b1984b591b5ddff3de859efbfc244a45d6ba557f
...
docker-user@docker-host:~$ sudo ip netns
da8436629985
default
...
docker-user@docker-host:~$ sudo ip netns exec da8436629985 ifconfig
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

А при запуске контейнера с network host создания нового namespace не происходит - используется default namespace.

3. Вот сети, созданные в рамках задания, которые мы видим с docker host:

sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
3605ea08404b        back_net            bridge              local
f43473e70d84        bridge              bridge              local
38367c9fe382        front_net           bridge              local
ba68257ac8e5        host                host                local
ea7aa3485a8b        none                null                local

4. Задать базовое имя проекта для docker-compose можно. Для этого нам нужно либо задать в ".env" файле переменную COMPOSE_PROJECT_NAME, либо вызывать "docker-compose up" с ключом "-p".

5. По заданию с "*":
а) Мы можем менять код приложения, но не пересобирать каждый раз образы, если в рамках docker-compose.override.yml примонтируем код с приложением как отдельный volume к контейнеру. Чтобы проверить эту гипотезу, я заливал views из ui репозитория на докер хост и чуть менял их, и затем монтировал в каталог /app/views приложения. 
б) Изменять в docker-compose.override.yml выполняемую при старте конейнера команду очень просто - пишем в сервисе что-то вроде:
command: "puma --debug -w 2"

Домашнее задание 14:

1. Первое задание с *:
Убедились, что мы можем использовать другие сетевые алиасы, если при запуске контейнеров заоверрайдим ENV переменные наших микросервисов (не меняя их Dockerfile). У меня получилось "собрать" рабочее приложение при запуске контейнеров таким образом:

docker run -d --network=reddit --network-alias=post_mongo --network-alias=comment_mongo mongo:latest
docker run -d --network=reddit -e POST_DATABASE_HOST=post_mongo --network-alias=post_python coloradobeetle/post:1.0
docker run -d --network=reddit -e COMMENT_DATABASE_HOST=comment_mongo --network-alias=comment_ruby coloradobeetle/comment:1.0
docker run -d --network=reddit -e POST_SERVICE_HOST=post_python -e COMMENT_SERVICE_HOST=comment_ruby -p 9292:9292 coloradobeetle/ui:1.0

2. Второе задание с *:

Пересобрали UI образ на основе alpine:3.8, образ уменьшился до 255 Мб. Немного оптимизировали команды Dockerfile, использовали опцию --no-cache для apk add. Есть еще пути уменьшить размер образа:
1) Подчистить за собой созданные в рамках установки пакетов файлы, кэш.
2) Использовать опцию --squash для сжатия созданных слоев в один.
3) Выполнять установку всех пакетов и зависимостей в рамках одной команды RUN.

Образы comment тоже несколько уменьшили, до 233 Мб.

Итоговый размер образов:
docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
coloradobeetle/ui            2.1                 852989f900e5        19 seconds ago      255MB
coloradobeetle/comment       2.0                 6f1c178b7eea        About an hour ago   233MB
coloradobeetle/ui            2.0                 253c98687f9d        2 hours ago         452MB
coloradobeetle/comment       1.0                 7dd94ca78ceb        18 hours ago        773MB
coloradobeetle/post          1.0                 3bb22cfb8c9f        18 hours ago        102MB

Домашнее задание 13:

1. В ходе работы над заданием познакомились и поработали с docker-machine, Docker hub и Dockerfile. Создали свой образ с приложением, протестировали его работу, залили его на Docker hub. Запустили контейнер с приложением на нашей docker-machine в GCP и на локальной машине.

2. Также описали в коде прототип для нашей инфраструктуры на основе Docker контейнеров (вспомнили тему IaC):
a) Описали образ ОС с установленным докером с помощью Packer.
b) С помощью кода Terraform сделали возможным поднятие VM (на основе этого Packer-образа) в GCP. Количество VM задается переменоой.
c) Написали три плейбука Ansible для установки докера и pip, загрузки нашего Docker image, запуска на VM контейнера на основе Docker image. Для dynamic inventory используется terraform-inventory.
