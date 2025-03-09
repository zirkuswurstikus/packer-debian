variable "user_name" {
  type    = string
  default = "vagrant"
}
variable "user_pwd" {
  type    = string
  default = "vagrant"
}
variable "output_dir" {
  type    = string
  default = "out"
}
variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}
variable "iso_checksum" {
  type    = string
  default = "sha512:04a2a128852c2dff8bb71779ad325721385051eb1264d897bdb5918ab207a9b1de636ded149c56c61a09eb8c7f428496815e70d3be31b1b1cf4c70bf6427cedd"
}

variable "iso_url" {
  description = <<EOF
* Current images in https://cdimage.debian.org/cdimage/release/
* Previous versions are in https://cdimage.debian.org/cdimage/archive/
EOF

  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-12.9.0-arm64-netinst.iso"
}


packer {
  required_plugins {
    parallels = {
      version = ">= 1.1.0"
      source  = "github.com/Parallels/parallels"
    }
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

source "parallels-iso" "parallels" {
  iso_url          = "${var.iso_url}"
  iso_checksum     = "${var.iso_checksum}"
  ssh_username     = "${var.user_name}"
  ssh_password     = "${var.user_pwd}"
  ssh_timeout      = "10m"
  shutdown_command = "echo '${var.user_pwd}' | sudo -S shutdown -P now"
  guest_os_type    = "debian"
  http_directory   = "./ressources/http/"
  boot_command = [
    "c",
    "linux /install.a64/vmlinuz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " netcfg/hostname=debian-12",
    " netcfg/get_domain=",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- quiet",
    "<enter>",
    "initrd /install.a64/initrd.gz",
    "<enter>",
    "boot",
    "<enter><wait>"
  ]
  memory                 = 2048
  cpus                   = 2
  disk_size              = 20480
  vm_name                = "packer_debian12_aarch64"
  output_directory       = "./outdir" # path for the vm during build, will be deleted
  parallels_tools_flavor = "lin-arm"
}

source "vmware-iso" "vmware" {
  iso_url          = "${var.iso_url}"
  iso_checksum     = "${var.iso_checksum}"
  ssh_username      = "${var.user_name}"
  ssh_password      = "${var.user_pwd}"
  ssh_timeout       = "5m"
  shutdown_command  = "echo '${var.user_pwd}' | sudo -S shutdown -P now"
  guest_os_type     = "arm-debian12-64"
  disk_adapter_type = "nvme"
  version           = 20
  http_directory    = "./ressources/http/"
  boot_command = [
    "c",
    "linux /install.a64/vmlinuz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " netcfg/hostname=debian-12",
    " netcfg/get_domain=",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- quiet",
    "<enter>",
    "initrd /install.a64/initrd.gz",
    "<enter>",
    "boot",
    "<enter><wait>"
  ]
  memory               = 2048
  cpus                 = 2
  disk_size            = 20480
  vm_name              = "Debian 12.0 (arm64)"
  network_adapter_type = "e1000e"
  output_directory     = "debian"
  usb                  = true
  vmx_data = {
    "usb_xhci.present" = "true"
  }
}

build {
  sources = ["sources.parallels-iso.parallels","sources.vmware-iso.vmware"]

  provisioner "shell" {
    execute_command = "echo '${var.user_pwd}' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    inline          = ["echo '%sudo    ALL=(ALL)  NOPASSWD:ALL' >> /etc/sudoers"]
  }

  provisioner "shell" {
    environment_vars = [
      "USER_NAME=${var.user_name}",
    ]
    #execute_command =  "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts = [
      "./ressources/scripts/create-user.sh",
      "./ressources/scripts/disable-ipv6.sh",
      #"./ressources/scripts/check-hypervisor.sh", # run before install.sh
      "./ressources/scripts/install.sh"
    ]
  }

  post-processor "vagrant" {
    compression_level              = 9
    vagrantfile_template_generated = true
    vagrantfile_template           = "./Vagrantfile"
    output                         = "out/debian12_aarch64_{{ .Provider }}.box"
  }
}
