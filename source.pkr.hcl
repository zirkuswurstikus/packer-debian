variable "user_name" {
  type    = string
  default = "vagrant"
}

variable "user_pwd" {
  type    = string
  default = "vagrant"
}

packer {
  required_plugins {
    parallels = {
      version = ">= 1.1.0"
      source  = "github.com/Parallels/parallels"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

source "parallels-iso" "debian" {
  iso_url          = "https://cdimage.debian.org/debian-cd/12.6.0/arm64/iso-cd/debian-12.6.0-arm64-netinst.iso"
  iso_checksum     = "sha512:f7be9783eca633c7cf176deaa350ab058a0ae70bb9cab4d880a4f67a918c58e67f269b18fe9dfa8fd4ef8116faf2ee7df5ac931de6e1ef0368978454ef3d2eac"
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
  vm_name                = "Packer: Debian 12.2 (arm64)"
  output_directory       = "out"
  parallels_tools_flavor = "lin-arm"
}

build {
  sources = ["sources.parallels-iso.debian"]

  provisioner "shell" {
    execute_command = "echo '${var.user_pwd}' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    inline          = ["echo '%sudo    ALL=(ALL)  NOPASSWD:ALL' >> /etc/sudoers"]
  }

  provisioner "shell" {
    environment_vars = [
      "USER_NAME=${var.user_name}",
      "PARALLELS=1"
    ]
    scripts = [
      "./ressources/scripts/create-user.sh",
      "./ressources/scripts/disable-ipv6.sh",
      "./ressources/scripts/install.sh"
    ]
  }

  post-processor "vagrant" {
    compression_level              = 9
    vagrantfile_template_generated = true
  }
}
