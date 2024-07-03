# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Specify the box file in the current directory
  config.vm.box = "packer_debian_parallels_arm64"
  config.vm.box_url = "./packer_debian_parallels_arm64.box"

  # Provider-specific configuration
  config.vm.provider :parallels do |prl|
    prl.name = "packer_debian_parallels_arm64"
    prl.memory = 2048
    prl.cpus = 2
  end

  # Network configuration
  config.vm.network "private_network", type: "dhcp"

  # Shared folders
  config.vm.synced_folder ".", "/vagrant"
  
config.vm.provision "shell", inline: <<-SHELL
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt clean
  SHELL
end
