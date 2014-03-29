#!/bin/bash

set -e

echo "## Setup Base Config ##"

# Updating and Upgrading dependencies
echo "## Performing full upgrade ##"
apt-get update -y -qq > /dev/null
apt-get upgrade -y -qq > /dev/null

# Install necessary libraries for guest additions and Vagrant NFS Share
echo "## Installing core packages ##"
apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common > /dev/null

# Install necessary packages 
echo "## Installing necessary packages ##"
apt-get -y -q install curl wget git vim ntp > /dev/null

# Setup sudo to allow no-password sudo for vagrant 
#(cat <<'vagrant ALL=NOPASSWD:ALL') > /tmp/vagrant
#chmod 0440 /tmp/vagrant
#mv /tmp/vagrant /etc/sudoers.d/

# Setup sudo to allow no-password for admin group
echo "## Setting up admin group sudo ##"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Set the history format
echo "## Setting up history format ##"
echo -e '# history timestamp\nexport HISTTIMEFORMAT="%F %T  "' > /etc/profile.d/histformat.sh
chmod 0755 /etc/profile.d/histformat.sh

# Set up vi as default editor
echo "## Setting up default editor ##"
update-alternatives --set editor /usr/bin/vim.tiny
