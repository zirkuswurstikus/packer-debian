Vagrant.configure("2") do |config|
  config.vm.box = "out/debian12_aarch64_parallels.box"
  config.vm.provider "parallels" do |prl|
    prl.name = "test_debian12_aarch64_parallels"
    prl.cpus = "2"
    prl.memory = "1024"
  end
  config.vm.network "public_network", type: "dhcp"
end
