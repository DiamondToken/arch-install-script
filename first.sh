#!/usr/bin/sh


DRIVE=$1
USER=$2
PASSWORD=$3


if [ "$(ls /sys/firmware/efi/efivars)" ]
then
    parted --script $DRIVE \
           mklabel gpt \
           mkpart primary ext4 0% 513MiB \
           mkpart primary ext4 513MiB 100%

    mkfs.ext4 ${DRIVE}2
    mount "${DRIVE}2" /mnt

    mkdir -p /mnt/boot/efi
    mkfs.fat -F32 /dev/${DRIVE}1
    mount "${DRIVE}1" /mnt/boot/efi
else
    parted --script $DRIVE \
           mklabel msdos \
           mkpart primary ext4 0% 100%

    mkfs.ext4 ${DRIVE}1
    mount "${DRIVE}1" /mnt
fi


pacstrap /mnt base base-devel linux linux-firmware vim grub efibootmgr os-prober dhcpcd zsh git stow

genfstab -U /mnt >> /mnt/etc/fstab

cp chroot-install.sh /mnt/
arch-chroot /mnt "/bin/bash" "./chroot-install.sh" "$DRIVE" "$USER" "$PASS"
