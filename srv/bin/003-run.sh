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
if [ -f "/srv/data/cfg/php.ini" ]; then
    export PHPRC=/srv/data/cfg/
else
    export PHPRC=/srv/cfg/
fi
/srv/bin/php-fpm start
#-------------------------------------------------------------------------#
echo "Starting database..."
/etc/init.d/mariadb start
#-------------------------------------------------------------------------#
if [ -z ${USE_APACHE+x} ]; then
    echo "Starting nginx..."
    if [ -f "/srv/data/cfg/nginx.cfg" ]; then
        nginx -c /srv/data/cfg/nginx.cfg -g "daemon off;"
    else
        nginx -c /srv/cfg/nginx.cfg -g "daemon off;"
    fi
else
    echo "Starting apache2..."
    mkdir -p /var/run/apache2
    export APACHE_RUN_DIR=/var/run/apache2
    export APACHE_LOCK_DIR=/var/lock/apache2
    if [ -f "/srv/data/cfg/apache2.conf" ]; then
        apache2 -f /srv/data/cfg/apache2.conf -D FOREGROUND
    else
        apache2 -f /srv/cfg/apache2.conf -D FOREGROUND
    fi
fi
#-------------------------------------------------------------------------#