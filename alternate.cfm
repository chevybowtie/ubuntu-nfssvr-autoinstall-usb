### Localization
d-i debian-installer/locale string en_US.UTF-8
d-i console-setup/ask_detect boolean false
d-i console-setup/layoutcode string us
d-i keyboard-configuration/xkb-keymap select us

### Network configuration
d-i netcfg/enable boolean true
d-i netcfg/choose_interface select auto
# d-i netcfg/disable_autoconfig boolean true
d-i netcfg/get_hostname string nfssvr
d-i netcfg/get_domain string local
d-i netcfg/get_ipaddress string 192.168.99.1
d-i netcfg/get_netmask string 255.255.255.0
d-i netcfg/get_gateway string 192.168.99.254
d-i netcfg/get_nameservers string 8.8.8.8 1.1.1.1
d-i netcfg/confirm_static boolean true

### Mirror
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

### Account setup
d-i passwd/root-login boolean false
d-i passwd/make-user boolean true
d-i passwd/user-fullname string Backup Admin
d-i passwd/username string backupadmin
# to generate a password hash for 'your-password', use the following command:
#    echo -n 'your-password' | openssl passwd -6 -stdin
d-i passwd/user-password-crypted password $6$y31rZMy1EuFFih7n$bcvDRp6xTSCAYnlRTWkZwnHOv5CjXnqNY9EOGmL7EK2fquxlr83whRZkFCSOMU6c6EBT.SkgR55RQJg6YMPNN/
d-i user-setup/allow-password-weak boolean true
d-i user-setup/allow-password-empty boolean false
d-i user-setup/encrypt-home boolean false
d-i user-setup/authorized-keys string AAAAB3NzaC1yc2EAAAADAQABAAACAQCXaWT8FBcf9JBWFthF6A66wotwe+kCiUrCyJokJL0aVjbi1NuqY1iA4JWo1DHZ4SgnpPWou2w0MCteRl/fGKLUyvx+K7VDEPYZYCupvP+E

### Clock and timezone setup
d-i clock-setup/utc boolean true
d-i time/zone string America/Chicago
d-i clock-setup/ntp boolean true

### Partitioning
d-i partman-partitioning/choose_label string gpt
d-i partman-auto/disk string /dev/sda
#### remove any lvm or raid partitions
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
#### use all space for LVM 
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
#### scheme
d-i partman-auto/choose_recipe select multi
#### finish
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish 
d-i partman/confirm boolean true 
d-i partman/confirm_nooverwrite boolean true



### Package selection
tasksel tasksel/first multiselect standard
d-i pkgsel/include string openssh-server nfs-kernel-server isc-dhcp-server
d-i pkgsel/upgrade select none



### Boot loader
# d-i grub-installer/with_other_os boolean true
# d-i grub-installer/bootdev string /dev/sda
# install grub
d-i grub-installer/force-efi-extra-removable boolean true
d-i grub-installer/only_debian boolean true


### Finish installation
# d-i preseed/early_command string \
#   dd if=/dev/zero of=/dev/sda bs=1M count=10 && \
#   wipefs --all /dev/sda && \
#   lsblk > /var/log/installer/lsblk.log && \
#   parted /dev/sda print > /var/log/installer/parted.log
# d-i finish-install/reboot_in_progress note
# d-i preseed/late_command string \
#   in-target mkdir -p /srv/nfs && \
#   in-target chown nobody:nogroup /srv/nfs && \
#   in-target bash -c 'grep -q "/srv/nfs 192.168.99.0/24(rw,sync,no_subtree_check,no_root_squash)" /etc/exports || echo "/srv/nfs 192.168.99.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports' && \
#   in-target systemctl enable nfs-server && \
#   in-target systemctl start nfs-server && \
#   in-target bash -c 'echo "subnet 192.168.99.0 netmask 255.255.255.0 {" > /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'echo "  range 192.168.99.10 192.168.99.20;" >> /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'echo "  option routers 192.168.99.1;" >> /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'echo "  option domain-name-servers 8.8.8.8;" >> /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'echo "  default-lease-time 600;" >> /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'echo "  max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'echo "}" >> /etc/dhcp/dhcpd.conf' && \
#   in-target bash -c 'iface=$(ls /sys/class/net | grep -v lo | head -n1); echo "INTERFACESv4=\\\"$iface\\\"" > /etc/default/isc-dhcp-server' && \
#   in-target systemctl enable isc-dhcp-server && \
#   in-target systemctl start isc-dhcp-server
