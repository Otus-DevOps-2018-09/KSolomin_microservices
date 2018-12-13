# KSolomin_microservices
KSolomin microservices repository

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
