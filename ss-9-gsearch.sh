#!/bin/bash

echo "Installing GSearch"

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Dependencies
cd /tmp
git clone https://github.com/discoverygarden/basic-solr-config.git
cd basic-solr-config
git checkout 4.x
cd islandora_transforms
sed -i 's#/usr/local/fedora/tomcat#${CATALINA_HOME}#g' ./*xslt

# dgi_gsearch_extensions
cd /tmp
git clone https://github.com/discoverygarden/dgi_gsearch_extensions.git
cd dgi_gsearch_extensions
mvn -q package

# Build GSearch
cd /tmp
git clone https://github.com/fcrepo3/gsearch.git
cd gsearch/FedoraGenericSearch
ant buildfromsource

# Deploy GSearch
cp -v /tmp/gsearch/FgsBuild/fromsource/fedoragsearch.war $CATALINA_HOME/webapps

# Sleep for 75 while Tomcat restart
echo "Sleeping for 75 while Tomcat stack restarts"
chown tomcat:tomcat $CATALINA_HOME/webapps/fedoragsearch.war
systemctl restart tomcat
sleep 45

# GSearch configurations
cd $CATALINA_HOME/webapps/fedoragsearch/WEB-INF/classes
wget -q http://alpha.library.yorku.ca/fgsconfigFinal.zip
unzip fgsconfigFinal.zip

# Deploy dgi_gsearch_extensions
cp -v /tmp/dgi_gsearch_extensions/target/gsearch_extensions-0.1.1-jar-with-dependencies.jar $CATALINA_HOME/webapps/fedoragsearch/WEB-INF/lib

# Solr & GSearch configurations
cp -v /tmp/basic-solr-config/conf/* $SOLR_HOME/collection1/conf
cp -Rv /tmp/basic-solr-config/islandora_transforms/* $CATALINA_HOME/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms
chown -hR tomcat:tomcat $SOLR_HOME
chown -hR tomcat:tomcat $CATALINA_HOME/webapps/fedoragsearch

# Restart Tomcat
chown tomcat:tomcat $CATALINA_HOME/webapps/fedoragsearch.war
systemctl restart tomcat

