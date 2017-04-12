#!/bin/bash

echo "Preparing to install Fedora."


#**how to symlink tomcat webapps to vhosts
# after the install of tomcat and tomcat-admin-webapps
# turn off tomcat
# mv /var/lib/tomcat/webapps to /vhosts/webapps
# then symlink /vhosts/webapps to /var/lib/tomcat/webapps 


# setup config-only env variables
# like version numbers for package download
if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi


# make Fedora database
# first has to be overall mysql admin user
echo "CREATE DATABASE fedora3" | mysql -uroot -p$MYSQLROOT
echo "CREATE USER $MYSQL_USER@'localhost' IDENTIFIED BY $MYSQL_PASS " | mysql -uroot -p$MYSQLROOT
echo "GRANT ALL ON fedora3.* TO $MYSQL_USER@'localhost'" | mysql -uroot -p$MYSQLROOT
echo "flush privileges" | mysql -uroot -p$MYSQLROOT


FEDORA_HOME="/vhosts/fedora"
# Prepare "$FEDORA_HOME"
if [ ! -d "$FEDORA_HOME" ]; then
  mkdir "$FEDORA_HOME"
fi
chown tomcat:tomcat "$FEDORA_HOME"
chmod g-w "$FEDORA_HOME"

echo "Downloading Fedora"
if [ ! -f "$DOWNLOAD_DIR/fcrepo-installer-3.8.1.jar" ]; then
  wget -q -O "/tmp/fcrepo-installer-3.8.1.jar" "https://github.com/fcrepo3/fcrepo/releases/download/v3.8.1/fcrepo-installer-3.8.1.jar"
else
  cp "$DOWNLOAD_DIR/fcrepo-installer-3.8.1.jar" "/tmp/fcrepo-installer-3.8.1.jar"
fi

echo "Installing Fedora"
java -jar /tmp/fcrepo-installer-3.8.1.jar "$SHARED_DIR"/configs/install.properties

# Check the exit code from the installation process
if [ $? -ne 0 ]; then
  # Had a corrupt jarfile in cache, if can't install then redownload it
  echo "Problem with jar file, redownloading"
  wget -q -O "/tmp/fcrepo-installer-3.8.1.jar" "https://github.com/fcrepo3/fcrepo/releases/download/v3.8.1/fcrepo-installer-3.8.1.jar"
  java -jar /tmp/fcrepo-installer-3.8.1.jar /tmp/install.properties

  if [ $? -ne 0 ]; then
    echo "Failed a second time to install from the Fedora jar... Can't proceed!"
    exit 1
  else
    # Copy files to the downloads directory if they were successfully used
    cp "/tmp/install.properties" "$DOWNLOAD_DIR/install.properties"
    cp "/tmp/fcrepo-installer-3.8.1.jar" "$DOWNLOAD_DIR/fcrepo-installer-3.8.1.jar"
  fi
fi

# Deploy fcrepo
chown tomcat:tomcat /var/lib/tomcat/webapps/fedora.war
chown -hR tomcat:tomcat "$FEDORA_HOME"
systemctl restart tomcat
echo "Sleeping while Fedora starts for the first time."
sleep 45

# Setup XACML Policies
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-inactive-or-deleted-objects-or-datastreams-if-not-administrator.xml
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-policy-management-if-not-administrator.xml
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-unallowed-file-resolution.xml
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-purge-datastream-if-active-or-inactive.xml
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-purge-object-if-active-or-inactive.xml
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-reloadPolicies-if-not-localhost.xml

cd "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/
git clone https://github.com/Islandora/islandora-xacml-policies.git islandora
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/islandora/permit-apim-to-anonymous-user.xml
rm "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/islandora/permit-upload-to-anonymous-user.xml

# Work around for issue #32 : Authentication error with Fedora API-M
# This probably isn't ideal, and I'm not sure if this is just an issue of working from a local desktop to vagrant vm, or something else sinister.
cp "$SHARED_DIR"/configs/deny-apim-if-not-localhost.xml "$FEDORA_HOME"/data/fedora-xacml-policies/repository-policies/default/deny-apim-if-not-localhost.xml

# Setup Drupal filter
wget -q -O "/tmp/fcrepo-drupalauthfilter-3.8.1.jar" https://github.com/Islandora/islandora_drupal_filter/releases/download/v7.1.3/fcrepo-drupalauthfilter-3.8.1.jar
cp -v "/tmp/fcrepo-drupalauthfilter-3.8.1.jar" /var/lib/tomcat/webapps/fedora/WEB-INF/lib
chown tomcat:tomcat /var/lib/tomcat/webapps/fedora/WEB-INF/lib/fcrepo-drupalauthfilter-3.8.1.jar
cp "$SHARED_DIR"/configs/jaas.conf "$FEDORA_HOME"/server/config
cp "$SHARED_DIR"/configs/filter-drupal.xml "$FEDORA_HOME"/server/config

# Restart Tomcat
systemctl restart tomcat

