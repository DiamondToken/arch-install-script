# ARGS:
# DRIVE
# USER
# PASS

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

hwclock --systohc

sed -i "/ru/s/^#//" "/etc/locale.gen"
sed -i "/en/s/^#//" "/etc/locale.gen"
sed -i "/fr/s/^#//" "/etc/locale.gen"
sed -i "/de/s/^#//" "/etc/locale.gen"
sed -i "/es/s/^#//" "/etc/locale.gen"
sed -i "/gr/s/^#//" "/etc/locale.gen"

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$2" > /etc/hostname

mkinitcpio -P

# read -t 1 -n 1000000 discard      # discard previous input


if [ "$(ls /sys/firmware/efi/efivars)" ] # uefi
then
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi $1
    grub-mkconfig -o /boot/grub/grub.cfg
else                                     # bios
    grub-install $1
    grub-mkconfig -o /boot/grub/grub.cfg
fi

useradd -m -G wheel -s /bin/zsh $2

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo "root:$3" | chpasswd
echo "$2:$3"    | chpasswd

echo "$2" > /etc/hostname

systemctl enable dhcpcd
