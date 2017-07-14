#!/bin/bash

echo "Installing MySQl and Drupal."


# Apache configuration file
#export APACHE_CONFIG_FILE=/etc/apache2/sites-enabled/000-default.conf

# begin drupal setup and apache config changes
#
# install mysql
yum -y mariadb mariadb-server php-mysql
# set root user pass to $MYSQLROOT

 cd /vhosts
# Download Drupal
drush dl drupal-7.x --drupal-project-rename=drupal

# Permissions
chown -R apache:apache drupal
chmod -R g+w drupal

# Do the install
cd drupal || exit
drush si -y --db-url=mysql://root:$MYSQLROOT@localhost/drupal7 --site-name=drupal
drush user-password admin --password=$ADMINPASS


# Set document root
#sed -i "s|DocumentRoot /vhosts/html$|DocumentRoot $DRUPAL_HOME|" $APACHE_CONFIG_FILE

# Set override for drupal directory
# Now inserting into VirtualHost container - whikloj (2015-04-30)
#if [ "$(grep -c "ProxyPass" $APACHE_CONFIG_FILE)" -eq 0 ]; then

## ignore the port settings for vagrant

#sed -i 's#<VirtualHost \*:80>#<VirtualHost \*:8000>#' $APACHE_CONFIG_FILE

#sed -i 's/Listen 80/Listen \*:8000/' /etc/apache2/ports.conf

#sed -i "/Listen \*:8000/a \
#NameVirtualHost \*:8000" /etc/apache2/ports.conf

read -d '' APACHE_CONFIG << APACHE_CONFIG_TEXT
	ServerAlias esb

	<Directory ${DRUPAL_HOME}>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ProxyRequests Off
	ProxyPreserveHost On

	<Proxy *>
		Order deny,allow
		Allow from all
	</Proxy>

	ProxyPass /fedora/get http://localhost:8080/fedora/get
	ProxyPassReverse /fedora/get http://localhost:8080/fedora/get
	ProxyPass /fedora/services http://localhost:8080/fedora/services
	ProxyPassReverse /fedora/services http://localhost:8080/fedora/services
	ProxyPass /fedora/describe http://localhost:8080/fedora/describe
	ProxyPassReverse /fedora/describe http://localhost:8080/fedora/describe
	ProxyPass /fedora/risearch http://localhost:8080/fedora/risearch
	ProxyPassReverse /fedora/risearch http://localhost:8080/fedora/risearch
	ProxyPass /adore-djatoka http://localhost:8080/adore-djatoka
	ProxyPassReverse /adore-djatoka http://localhost:8080/adore-djatoka
APACHE_CONFIG_TEXT

sed -i "/<\/VirtualHost>/i $(echo "|	$APACHE_CONFIG" | tr '\n' '|')" $APACHE_CONFIG_FILE
tr '|' '\n' < $APACHE_CONFIG_FILE > $APACHE_CONFIG_FILE.t 2> /dev/null; mv $APACHE_CONFIG_FILE{.t,}

fi

# Torch the default index.html
rm /var/www/html/index.html

# Cycle apache
systemctl restart httpd

# Make the modules directory
if [ ! -d sites/all/modules ]; then
  mkdir -p sites/all/modules
fi
cd sites/all/modules || exit

# Modules
drush dl devel imagemagick ctools jquery_update pathauto xmlsitemap views variable token libraries datepicker date
drush -y en devel imagemagick ctools jquery_update pathauto xmlsitemap views variable token libraries datepicker_views

drush dl coder-7.x-2.5
drush -y en coder

# php.ini templating
cp -v "$SHARED_DIR"/configs/php.ini /etc/php5/apache2/php.ini

systemctl restart httpd

# sites/default/files ownership
chown -hR www-data:www-data /vhosts/drupal/sites/default/files

# Run cron
cd /vhosts/drupal/sites/all/modules || exit
drush cron

