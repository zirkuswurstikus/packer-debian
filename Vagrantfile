# vi: syntax=ruby
# vi: filetype=ruby

Vagrant.configure("2") do |config|
  #config.vm.box = "debian12_aarch64_parallels"
  config.vm.synced_folder "./", "/vagrant"
  config.vm.network "public_network", type: "dhcp"
  config.vm.box = "debian12_aarch64"

  config.vm.provider "parallels" do |prl, override|
    override.vm.box_url = "file://#{File.expand_path('out/debian12_aarch64_parallels.box')}"
    prl.name = "test_debian12_aarch64"
    prl.cpus = 2
    prl.memory = 1024
    prl.check_guest_tools = true
    prl.update_guest_tools = true
  end

  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box_url = "file://#{File.expand_path('out/debian12_aarch64_vmware.box')}"
    v.vmx['displayname'] = "test_debian12_aarch64"
    v.gui=true
    v.cpus = 2
    v.memory = 1024
    v.vmx["ethernet0.pcislotnumber"] = "160"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provision/playbook.yaml"
    #provisioning_path = "provision/"
    #config_file = "./ansible.cfg"
  end
end
