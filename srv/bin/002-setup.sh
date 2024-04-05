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
