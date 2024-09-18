#!/usr/bin/sh


DRIVE=$1
USER=$2
PASS=$3

make_bios()
{
    #1 drive;

    echo "ARG is: $1"

    parted --script $1 \
           mklabel msdos \
           mkpart primary ext4 0% 100%

    mkfs.ext4 "${1}1"

    mount "${1}1" /mnt
}


make_efi()
{
     # $1 # drive
     # $2 # target

    parted --script $1 \
           mklabel gpt \
           mkpart primary ext4 0% 513MiB \
           mkpart primary ext4 513MiB 100%

    mkfs.ext4 ${1}2
    mount "${1}2" /mnt

    mkdir -p /mnt/boot/efi
    mkfs.fat -F32 /dev/${1}1
    mount "${1}1" /mnt/boot/efi
}

if_uefi()
{
    [ "$(ls /sys/firmware/efi/efivars)" ]
}

if_uefi && make_efi || make_bios $DRIVE

pacstrap /mnt base base-devel linux linux-firmware vim grub efibootmgr os-prober dhcpcd zsh zsh-syntax-highlighting git stow make
genfstab -U /mnt >> /mnt/etc/fstab

cp chroot-install.sh /mnt/
arch-chroot /mnt "/bin/bash" "./chroot-install.sh" "$DRIVE" "$USER" "$PASS"
