# ubuntu-nfssvr-autoinstall-usb

Creates a bootable Ubuntu Server USB installer that automatically:
- Wipes the system disk
- Sets up a minimal OS with NFS and DHCP server
- Uses autoinstall and cloud-init

Run `make-autoinstall-usb.sh` on a Linux system and plug the USB into your mini PC to set it up as a backup server.

Edit the script to add your SSH key and password hash.
