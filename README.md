# ubuntu-nfssvr-autoinstall-usb

This project automates the creation of a bootable Ubuntu Server USB drive that performs a **fully unattended installation**. The installed system will act as a **backup server** with:

- A static IP address (`192.168.99.1`)
- An **NFS server** at `/srv/nfs`
- A **DHCP server** that assigns addresses in the range `192.168.99.10–20`
- SSH enabled (via your provided public key)

---

## 🔧 What This Script Does

The `make-autoinstall-usb.sh` script:

1. Downloads the Ubuntu Server ISO
2. Writes it to a USB drive
3. Injects autoinstall configuration for:
   - Disk wipe + partitioning
   - Static IP
   - NFS and DHCP server installation
   - SSH key-based login
4. Modifies GRUB to automatically trigger autoinstall

---

## 🚀 Using the USB Installer

1. **Plug the USB drive into your mini PC**
2. Boot from USB
3. The installer will automatically configure everything
4. When finished, the mini PC will:
   - Have a user named `backupadmin`
   - Be accessible via SSH if connected to the network
   - Serve `/srv/nfs` over NFS
   - Provide DHCP to clients on the `192.168.99.0/24` subnet

---

## 🖥️ How to Connect from a Client

Assuming you have a second PC with a free NIC:

### 📌 Option 1: Automatically via DHCP

1. Connect the client PC to the mini PC with an Ethernet cable
2. Set the NIC to use DHCP
3. It should receive an IP in the range `192.168.99.10–20`

Check:
```bash
ip a  # to confirm IP
```

Then:
```bash
sudo mount 192.168.99.1:/srv/nfs /mnt
```

To make it persistent, add this to `/etc/fstab`:
```
192.168.99.1:/srv/nfs /mnt nfs defaults 0 0
```

---

### 📌 Option 2: Manual IP Assignment

If DHCP isn't working:

1. Assign a static IP on the second PC (e.g., `192.168.99.2/24`)
2. Then mount:
```bash
sudo mount 192.168.99.1:/srv/nfs /mnt
```

---

## 🔐 SSH Access

To SSH into the server:

```bash
ssh backupadmin@192.168.99.1
```

(Ensure your SSH public key was included in the autoinstall config.)

---

## ⚠️ Warning

- This installation **wipes the entire disk** on the target mini PC.
- Use caution and verify target disks before booting with this USB.

---

## 🧪 Tested On

- Ubuntu Server 22.04.4 LTS ISO
- USB boot via BIOS/UEFI
- Headless mini PCs with 1 NIC or more

---

## 💡 Future Ideas

- Add Borg or rsnapshot for scheduled backups
- Export multiple NFS volumes
- Add cron jobs or `rsync` hooks
