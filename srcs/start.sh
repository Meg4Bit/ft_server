#!/bin/bash

sed -i "s/DOCKER_HOST_IP/$DOCKER_HOST_IP/" /etc/nginx/sites-available/default
service nginx start
service mysql start
service php7.3-fpm start
bash
