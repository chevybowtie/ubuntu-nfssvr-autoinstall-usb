#!/bin/bash

set -euo pipefail

# === CONFIGURABLE ===
UBUNTU_VERSION="22.04.4"
ISO_NAME="ubuntu-${UBUNTU_VERSION}-live-server-amd64.iso"
ISO_URL="https://releases.ubuntu.com/${UBUNTU_VERSION}/${ISO_NAME}"
USB_DEVICE="/dev/sdX" # ⚠️ Replace this with your actual USB device (e.g., /dev/sdb)

USERNAME="backupadmin"
HASHED_PASS='$6$rounds=4096$change_this_to_a_valid_hash'
SSH_KEY='ssh-rsa AAAA... your_key_here'

STATIC_IP="192.168.99.1/24"
NIC_NAME="enp1s0"

# === Download ISO ===
if [ ! -f "$ISO_NAME" ]; then
  echo "Downloading Ubuntu Server ISO..."
  wget "$ISO_URL"
fi

# === Write ISO to USB ===
echo "Writing ISO to USB ($USB_DEVICE)..."
sudo dd if="$ISO_NAME" of="$USB_DEVICE" bs=4M status=progress oflag=sync

# === Mount USB ===
echo "Mounting USB..."
sleep 3
MOUNT_POINT="/mnt/usb"
mkdir -p "$MOUNT_POINT"
sudo mount "${USB_DEVICE}1" "$MOUNT_POINT"

# === Create autoinstall files ===
echo "Creating autoinstall config..."
AUTOINSTALL_DIR="$MOUNT_POINT/nocloud"
sudo mkdir -p "$AUTOINSTALL_DIR"

cat <<EOF | sudo tee "$AUTOINSTALL_DIR/user-data" > /dev/null
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: nfs-backup-box
    username: ${USERNAME}
    password: ${HASHED_PASS}
  ssh:
    install-server: true
    authorized-keys:
      - ${SSH_KEY}
  locale: en_US
  keyboard:
    layout: us
  timezone: America/Chicago
  storage:
    layout:
      name: direct
    wipe: true
  network:
    version: 2
    ethernets:
      ${NIC_NAME}:
        dhcp4: false
        addresses: [${STATIC_IP}]
        gateway4: ${STATIC_IP%/*}
        nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
  packages:
    - nfs-kernel-server
    - isc-dhcp-server
  late-commands:
    - curtin in-target -- mkdir -p /srv/nfs
    - curtin in-target -- chown nobody:nogroup /srv/nfs
    - curtin in-target -- bash -c 'echo "/srv/nfs 192.168.99.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports'
    - curtin in-target -- systemctl enable nfs-server
    - curtin in-target -- bash -c 'cat <<EOL > /etc/dhcp/dhcpd.conf
subnet 192.168.99.0 netmask 255.255.255.0 {
  range 192.168.99.10 192.168.99.20;
  option routers 192.168.99.1;
  option domain-name-servers 8.8.8.8;
  default-lease-time 600;
  max-lease-time 7200;
}
EOL'
    - curtin in-target -- bash -c 'echo "INTERFACESv4=\\"${NIC_NAME}\\"" > /etc/default/isc-dhcp-server'
    - curtin in-target -- systemctl enable isc-dhcp-server
EOF

sudo touch "$AUTOINSTALL_DIR/meta-data"

# === Patch GRUB ===
echo "Patching GRUB..."
GRUB_CFG="$MOUNT_POINT/boot/grub/grub.cfg"
sudo sed -i "/menuentry 'Try or Install Ubuntu Server'/,/^}/ s|linux /casper/vmlinuz.*|& autoinstall ds=nocloud\\\;s=/cdrom/nocloud/|" "$GRUB_CFG"

# === Done ===
echo "Syncing and unmounting..."
sync
sudo umount "$MOUNT_POINT"
echo "✅ USB autoinstall disk is ready to use!"
