#!/bin/bash

# this is for a RHEL 7 or centos 7 server

# at this point there is a new install and
# a sysadmin has set up the users and NFS shares.
# there should be a linux user "islandora" or any other user specifically for
# this installation
#
#
# detect centos versus redhat
$OS="centos"
if [ ! -f "/etc/centos-release" ]; then
  $OS="redhat"
fi

# --- install additional packages
# setup timezone
sudo timedatectl set-timezone America/New_York

# utilities
yum -y install wget curl mc mutt screen bzip2 zip unzip ntp psmisc tree zsh

# Build tools
yum -y install gcc kernel-devel kernel-headers autoconf

# add epel repo for dkms
yum -y install epel-release
yum -y install dkms

# Git vim
yum -y install git vim

# --------------------- if Centos 7 ....
if [$OS = "centos"]; then
  ## add openjdk8 java and remove openjdk7
  yum -y install java-1.8.0-openjdk
  echo '*******removing java openjdk7********'
  yum -y remove java-1.7.0-openjdk
  # Java 8 (Oracle)
  wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/jdk-8u131-linux-x64.rpm
  rpm -Uvh jdk-8*
  rm -f jdk-8*
  ## make java 8 default with the alternatives command
  sudo alternatives  --set java /usr/java/jdk1.8.0_131/jre/bin/java
  ## Set JAVA_HOME variable both now and for when the system restarts
  export JAVA_HOME
else
  #------------------ if RHEL 7
  yum -y java-1.8.0-oracle  java-1.8.0-oracle-devel
fi

# Maven
apt-get -y install maven

# Tomcat
apt-get -y install tomcat tomcat-admin-webapps

echo "****** Basic Stage 1 of server install is finished.*******"
echo " "
