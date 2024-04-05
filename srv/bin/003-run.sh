#!/bin/sh
#-------------------------------------------------------------------------#
echo "Cleaning temp..."
set -e
rm -f -R /srv/tmp/*
#-------------------------------------------------------------------------#
echo "Starting cron..."
cron
#-------------------------------------------------------------------------#
echo "Starting ssh..."
ssh-keygen -A
/usr/sbin/sshd -D -e&
#-------------------------------------------------------------------------#
echo "Creating self signed certificate..."
openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /srv/data/cert/localhost.crt -keyout /srv/data/cert/localhost.key -subj "/C=/ST=/L=/O=/OU=/CN=localhost"
#-------------------------------------------------------------------------#
echo "Starting php..."
export PHPRC=/srv/data/cfg/
./etc/init.d/php8.2-fpm start
#-------------------------------------------------------------------------#
echo "Starting database..."
/etc/init.d/mariadb start
#-------------------------------------------------------------------------#
echo "Starting nginx..."
nginx -c /srv/data/cfg/nginx.cfg -g "daemon off;"
#-------------------------------------------------------------------------#