#!/bin/bash

set -e

STEPS_DONE=0

if [ "$STEPS_DONE" -eq 0 ]; then
    echo "Before running this script, the following steps must be completed:"
    echo ""
    echo "0. Confirm the correct date and time"
    echo ""
    echo "1. Partition the disks"
    echo " For example:"
    echo "  parted /dev/sda"
    echo "  rm 1"
    echo "  mkpart primary ext4 1MiB 100%"
    echo "  set 1 boot on"
    echo "  select /dev/sdb"
    echo "  rm 1"
    echo "  mkpart primary ext4 1MiB 100%"
    echo "  q"
    echo ""
    echo "2. Format the partitions"
    echo "  mkfs.ext4 /dev/sda1"
    echo "  mkfs.ext4 /dev/sdb1"
    echo ""
    echo "3. Mount the file systems"
    echo "  mount /dev/sda1 /mnt"
    echo "  mkdir /mnt/home"
    echo "  mount /dev/sdb1 /mnt/home"
    echo ""
    echo "4. Install System"
    echo "  pacman --needed -Syy archlinux-keyring parabola-keyring"
    echo "  pacstrap /mnt base"
    echo "  pacstrap /mnt linux-libre-lte"
    echo "  pacstrap /mnt networkmanager"
    echo "  pacstrap /mnt parabola-base"
    echo "  pacstrap /mnt grub"
    echo "  pacstrap /mnt syslinux"
    echo "  pacstrap /mnt git vim"
    echo "  genfstab -p /mnt >> /mnt/etc/fstab"
    echo "  arch-chroot /mnt"
    echo ""
    echo "Once these steps have been completed, set STEPS_DONE above to 1"
    exit
fi

echo "Proceeding with installation..."

set -x

echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.0.1     ragnar.localdomain ragnar" >> /etc/hosts
echo "ragnar" > /etc/hostname

ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

pacman -S --noconfirm base-devel sudo xorg-server xorg-apps libxinerama libxft mesa xf86-video-nouveau gnu-free-fonts

systemctl enable NetworkManager.service

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo root:password | chpasswd
useradd -m paul
echo paul:password | chpasswd

pacman --needed -Syy archlinux-keyring parabola-keyring
pacman -Syu

echo "Done. Now: exit; umount -a; reboot"
