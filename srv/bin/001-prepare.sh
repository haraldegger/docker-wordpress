#!/bin/sh
#-------------------------------------------------------------------------#
echo "Installing applications..."
export DEBIAN_FRONTEND="noninteractive"
apt-get -y update
apt-get -y upgrade
apt-get -y install nginx
apt-get -y install apache2
apt-get -y install mariadb-server
apt-get -y install php8.2-fpm
apt-get -y install php8.2-mysql
apt-get -y install php8.2-gd
apt-get -y install php8.2-xml
apt-get -y install php8.2-zip
apt-get -y install php8.2-imagick
apt-get -y install php8.2-mbstring
apt-get -y install php8.2-curl
apt-get -y install php8.2-bcmath
apt-get -y install php8.2-opcache
apt-get -y install php-json
apt-get -y install openssl
apt-get -y install openssh-server
apt-get -y install cron
apt-get -y install wget
apt-get -y install nano #for convenience, when manually interventing on the system
#-------------------------------------------------------------------------#
echo "Executing mysql_secure_installation..."
/etc/init.d/mariadb start
mysql_secure_installation <<EOF

n
n
y
y
y
y
EOF
#-------------------------------------------------------------------------#
cd /srv/tmp/
wget https://wordpress.org/wordpress-6.6.2.tar.gz
tar -xvzf wordpress-6.6.2.tar.gz
mv wordpress/* /srv/data/www/
rm wordpress-6.6.2.tar.gz
#-------------------------------------------------------------------------#