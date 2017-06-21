#!/bin/bash

echo "Installing FITS"
SHARED_DIR=/home/islandora/setup
# setup config-only env variables
if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi
#FITS_HOME=/vhosts/fits

# Setup FITS_HOME
if [ ! -d "$FITS_HOME" ]; then
  mkdir "$FITS_HOME"
fi
chown islandora:islandora "$FITS_HOME"

# Download and deploy FITS
wget -q -O "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" "https://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip"

unzip "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" -d "$FITS_HOME"
cd "$FITS_HOME/fits-$FITS_VERSION"
mv "$FITS_HOME/fits-$FITS_VERSION" "$FITS_HOME/fits"
cd "$FITS_HOME/fits"
chmod +x fits.sh
chmod +x fits-env.sh

echo "Installing Tesseract"

yum -y install tesseract tesseact-osd tesseract-langpack-fra

