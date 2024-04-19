#!/bin/sh
#-------------------------------------------------------------------------#
#installing additional packages if requested
 if [ ! -z ${MY_PACKAGES+x} ]; then
    echo "Installing additional packages..."
    export DEBIAN_FRONTEND="noninteractive"
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install $MY_PACKAGES
fi
#creating new user
echo "Creating new user..."
if [ -z ${MY_USERNAME+x} ]; then
    echo "At least one ENV variable was not provided, please recreate the container and pass MY_USERNAME to it"
    echo "#!/bin/sh" > /srv/bin/start.sh
    echo "echo At least one ENV variable was not provided, please recreate the container and pass MY_USERNAME to it" >> /srv/bin/start.sh
    echo "sleep 60" >> /srv/bin/start.sh
    exit
fi
if [ -z ${MY_PASSWORD+x} ]; then
    echo "At least one ENV variable was not provided, please recreate the container and pass MY_PASSWORD to it"
    echo "#!/bin/sh" > /srv/bin/start.sh
    echo "echo At least one ENV variable was not provided, please recreate the container and pass MY_PASSWORD to it" >> /srv/bin/start.sh
    echo "sleep 60" >> /srv/bin/start.sh
    exit
fi
useradd $MY_USERNAME
echo "$MY_USERNAME:$MY_PASSWORD" | chpasswd
usermod -g root $MY_USERNAME
usermod -d /srv/ $MY_USERNAME
#-------------------------------------------------------------------------#
echo "Setting up folder rights..."
chmod -R 775 /srv/*
chmod 755 /srv/
chown -R mysql:mysql /srv/data/db
chmod -R 750 /srv/data/db
chown www-data:www-data -R /srv/data/www/
find /srv/data/www/ -type d -exec chmod 755 {} \;
find /srv/data/www/ -type f -exec chmod 644 {} \;
chmod 777 /srv/data/www
#-------------------------------------------------------------------------#
echo "Setup database..."
if [ ! -d "/srv/data/db/mysql" ]; then
    if [ -z ${DB_USERNAME+x} ]; then
        export DB_USERNAME=$MY_USERNAME
    fi
    if [ -z ${DB_PASSWORD+x} ]; then
        export DB_PASSWORD=$MY_PASSWORD
    fi
    if [ -z ${DB_NAME+x} ]; then
        export DB_NAME=wordpress
    fi
    cp -R /var/lib/mysql/* /srv/data/db/
    chown -R mysql:mysql /srv/data/db
    chmod -R 750 /srv/data/db
    #adding our config files
    echo '!includedir /srv/cfg/' >> /etc/mysql/mariadb.cnf
    echo '!includedir /srv/data/cfg/' >> /etc/mysql/mariadb.cnf
    #launching db
    /etc/init.d/mariadb start
    #creating db and user
    mysql -e "CREATE DATABASE $DB_NAME"
    mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USERNAME@localhost IDENTIFIED BY '$DB_PASSWORD'"
else
    echo '!includedir /srv/cfg/' >> /etc/mysql/mariadb.cnf
    echo '!includedir /srv/data/cfg/' >> /etc/mysql/mariadb.cnf
fi
#-------------------------------------------------------------------------#
echo "Setting up php fpm..."
echo "[global]" > /etc/php/8.2/fpm/php-fpm.conf
echo "pid = /run/php/php8.2-fpm.pid" >> /etc/php/8.2/fpm/php-fpm.conf
echo "error_log = /srv/data/log/php-fpm.log" >> /etc/php/8.2/fpm/php-fpm.conf
echo "include=/srv/cfg/php-fpm.conf" >> /etc/php/8.2/fpm/php-fpm.conf
echo "include=/srv/data/cfg/php-fpm.conf" >> /etc/php/8.2/fpm/php-fpm.conf
#-------------------------------------------------------------------------#
echo "Setting up SFTP for file transfer..."
mkdir /run/sshd
echo "Port 22" > /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
echo "AllowAgentForwarding no" >> /etc/ssh/sshd_config
echo "AllowUsers $MY_USERNAME" >> /etc/ssh/sshd_config
echo "PermitTunnel no" >> /etc/ssh/sshd_config
echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
echo "ChrootDirectory %h" >> /etc/ssh/sshd_config
#-------------------------------------------------------------------------#
