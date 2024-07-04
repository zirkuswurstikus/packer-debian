#!/bin/bash
set -e
set -u
#set -o pipefail
IFS=$'\n\t'

sudo apt-get update -y

# Set HYPERVISOR= variable based on hypervisor ;)
# Tested on Apple Silicon M1
#   - Paralles Desktop 13 Pro, HYPERVISOR=parallels
#   - VMWare Fusion 13 Pro, HYPERVISOR=vmware
#
# default:
#   HYPERVISOR=unknown

# Function to check if running inside VMware
is_vmware() {
    if grep -q "VMware" /proc/scsi/scsi 2>/dev/null; then
        return 0
    elif dmesg | grep -q "VMware Virtual Platform" 2>/dev/null; then
        return 0
    elif dmidecode -s system-product-name 2>/dev/null | grep -q "VMware Virtual Platform"; then
        return 0
    else
        return 1
    fi
}

# Function to check if running inside Parallels
is_parallels() {
    if dmesg | grep -q "Parallels" 2>/dev/null; then
        return 0
    elif dmidecode -s system-product-name 2>/dev/null | grep -q "Parallels Virtual Platform"; then
        return 0
    else
        return 1
    fi
}

# Check if running inside VMware
if is_vmware; then
    export HYPERVISOR=vmware
    echo "HYPERVISOR set to vmware"
# Check if running inside Parallels
elif is_parallels; then
    export HYPERVISOR=parallels
    echo "HYPERVISOR set to parallels"
# Default
else
    export HYPERVISOR=unknown
    echo "HYPERVISOR set to unknown"
fi



if [[ ${HYPERVISOR} == "parallels" ]]; then
  mkdir -p /tmp/parallels;
  sudo mount -o loop /home/"$USER_NAME"/prl-tools-lin-arm.iso /tmp/parallels;

  sudo /tmp/parallels/install --install-unattended-with-deps --progress
  sudo umount /tmp/parallels;
  rm -rf /tmp/parallels;
  rm -f /home/"$USER_NAME"/*.iso;
fi

if [[ ${HYPERVISOR} == "vmware" ]]; then
  sudo apt-get install open-vm-tools
fi

sudo apt-get install curl apt-transport-https gpg openssl net-tools unzip -y

sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get clean -y
sudo apt-get autoclean -y
sudo apt-get autoremove -y

cat /dev/null >~/.bash_history

# sudo passwd -l "$USER_NAME"
# sudo passwd -d "$USER_NAME"
# sudo usermod -L "$USER_NAME"

# 
sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY

if [[ ${HYPERVISOR} == "vmware" ]]; then
  sync
  sudo vmware-toolbox-cmd disk shrink /
fi

