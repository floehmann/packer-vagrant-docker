#!/bin/bash

set -e

echo "## Setup Dev Config for a generic test box ##"

# Updating and Upgrading dependencies
echo "## Performing full upgrade ##"
apt-get update -y -qq > /dev/null
apt-get upgrade -y -qq > /dev/null

# 
sudo apt-get -y -q install python-setuptools autoconf ant openjdk-7-jdk autotools-dev libcppunit-1.13-0 libcppunit-dev python-dev golang checkinstall cmake 

# 
sudo easy_install pip
sudo pip install virtualenv
sudo pip install virtualenvwrapper
mkdir /home/vagrant/.virtualenvs
chown vagrant:vagrant /home/vagrant/.virtualenvs

