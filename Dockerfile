# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ametapod <pe4enko111@rambler.ru>           +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/09/07 11:32:51 by ametapod          #+#    #+#              #
#    Updated: 2020/09/07 11:32:51 by ametapod         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster
LABEL maintainer="ametapod"
# Устанавливаем зависимости
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install nginx vim
RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring
RUN apt-get -y install certbot python-certbot-nginx
# Задаём текущую рабочую директорию
WORKDIR /var/www/html/
# Копируем код из локального контекста
COPY ./srcs/wordpress.tar.gz .
COPY ./srcs/phpMyAdmin.tar.gz .

RUN rm -f index.nginx-debian.html

RUN tar xzvf ./phpMyAdmin.tar.gz && rm -rf phpMyAdmin.tar.gz
RUN mv phpMyAdmin-5.0.2-all-languages phpMyAdmin
COPY ./srcs/config.inc.php phpMyAdmin

RUN tar xzvf ./wordpress.tar.gz && rm -rf wordpress.tar.gz

COPY ./srcs/start.sh /var/
COPY ./srcs/mysql_setup.sql /var/
COPY ./srcs/wordpress.sql /var/
COPY ./srcs/autoindex.sh .
COPY ./srcs/nginx.conf /etc/nginx/sites-available/default

RUN service mysql start && mysql < /var/mysql_setup.sql && mysql wordpress < /var/wordpress.sql
RUN openssl req -x509 -batch -new -newkey rsa:2048 -nodes -keyout /etc/ssl/certs/localhost.key -subj '/C=RU/ST=Moscow/L=Moscow/O=21 school/CN=localhost.com' -out /etc/ssl/certs/localhost.csr
#RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=RU/ST=RU/L=Moscow/O=School21/CN=tcarlena' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
RUN chown -R www-data:www-data *
RUN chmod 755 -R *

# Настраиваем команду, которая должна быть запущена в контейнере во время его выполнения
ENTRYPOINT bash /var/start.sh

# Открываем порты
EXPOSE 80 443
