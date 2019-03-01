#!/bin/bash

echo "Installing Apache and PHP for a RHEL 7 server."

# setup config-only env variables
# like version numbers for package download
if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi
# add apache server and mod_ssl
yum -y install httpd mod_ssl httpd-tools

# put the islandora user into the apache group
usermod -a -G apache islandora

# Add web group, and put some users in it --?? not sure the function of this??
groupadd web
usermod -a -G web apache
usermod -a -G web islandora
usermod -a -G web tomcat

# Apache configuration file
#export APACHE_CONFIG_FILE=/etc/apache2/sites-enabled/000-default.conf

# add epel repo
sudo yum -y install epel-release
sudo yum update

# setup timezone
sudo timedatectl set-timezone America/New_York

# disable selinux
sudo sed -i 's|SELINUX=enforcing$|SELINUX=disabled|' /etc/selinux/config
sudo touch /.autorelabel

# utilities and build tools
sudo yum -y install wget mc zip unzip ntp psmisc gcc kernel-devel kernel-headers autoconf git vim htop tree mc zsh net-tools
# recent (Jan 2019) changes have kept php 7.2 from working.
# add remi repo and enable php56
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-plugin-priorities
sudo yum-config-manager --enable remi-php56

# Drush and drupal deps
yum -y install php-gd php-devel php-xml php-soap php-curl
yum -y install php-pecl-imagick ImageMagick perl-Image-ExifTool bibutils poppler-utils
pecl install uploadprogress
sed -i '/; extension_dir = "ext"/ a\ extension=uploadprogress.so' /etc/php.ini
# drush from rhel
yum -y install drush
