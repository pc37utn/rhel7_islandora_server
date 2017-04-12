#!/bin/bash

echo "Installing Solr"

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Download Solr
if [ ! -f "$DOWNLOAD_DIR/solr-$SOLR_VERSION.tgz" ]; then
  echo "Downloading Solr"
  wget -q -O "$DOWNLOAD_DIR/solr-$SOLR_VERSION.tgz" "http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz"
fi
cd /tmp
cp "$DOWNLOAD_DIR/solr-$SOLR_VERSION.tgz" /tmp
tar -xzvf solr-"$SOLR_VERSION".tgz

# Prepare SOLR_HOME
if [ ! -d "$SOLR_HOME" ]; then
  mkdir "$SOLR_HOME"
fi
cd /tmp/solr-"$SOLR_VERSION"/example/solr
mv -v ./* "$SOLR_HOME"
chown -hR tomcat:tomcat "$SOLR_HOME"

# Deploy Solr
cp -v "/tmp/solr-$SOLR_VERSION/dist/solr-$SOLR_VERSION.war" "$CATALINA_HOME/webapps/solr.war"
chown tomcat:tomcat $CATALINA_HOME/webapps/solr.war
ln -s "$SOLR_HOME" $CATALINA_HOME/solr

# Restart Tomcat
systemctl restart tomcat
