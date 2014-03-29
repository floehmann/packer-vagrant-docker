#!/bin/bash

set -e

echo "## Installing Docker ##"

# Install docker
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
apt-get update -y -qq > /dev/null
apt-get -y -q install lxc-docker cgroup-lite > /dev/null

# non root access
gpasswd -a vagrant docker

# enable swap and cpu accounting
cp /etc/default/grub /root/grub.orig
sed -i -e 's!GRUB_CMDLINE_LINUX=""!GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"!g' /etc/default/grub
