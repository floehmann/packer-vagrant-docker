# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base
  config.vm.box = "docker_box"
  config.vm.hostname = "docker-test"

  # Network
  config.vm.network :private_network, ip: "192.168.56.5"
  config.vm.network :forwarded_port, guest: 22, host: 2258

  # Forward X11
  #config.ssh.forward_x11 = true

  ## Using NFS as it has much better performance
  ## On linux install nfs-kernel-server, MacOS works by default
  ## Will ask for root password to set some things up
  config.vm.synced_folder ".", "/vagrant", :nfs => true
end
