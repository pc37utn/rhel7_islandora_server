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

# Drush and drupal deps
yum -y install php-gd php-devel php-xml php-soap php-curl
yum -y install php-pecl-imagick ImageMagick perl-Image-ExifTool bibutils poppler-utils
pecl install uploadprogress
sed -i '/; extension_dir = "ext"/ a\ extension=uploadprogress.so' /etc/php.ini
# drush from rhel
yum -y install drush
