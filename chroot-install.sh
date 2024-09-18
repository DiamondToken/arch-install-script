# ARGS:
# DRIVE
# USER
# PASS

DRIVE=$1
USER=$2
PASS=$3

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

echo "$USER" > /etc/hostname

mkinitcpio -P


if [ "$(ls /sys/firmware/efi/efivars)" ] # uefi
then
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi $DRIVE
    grub-mkconfig -o /boot/grub/grub.cfg
else                                     # bios
    grub-install $DRIVE
    grub-mkconfig -o /boot/grub/grub.cfg
fi

useradd -m -G wheel -s /bin/zsh $USER

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo "root:$PASS"  | chpasswd
echo "$USER:$PASS" | chpasswd

echo "$USER" > /etc/hostname

systemctl enable dhcpcd
systemctl start  dhcpcd

git clone https://github.com/DiamondToken/dwm.git           "/home/$USER/dwm"
git clone -b flood_again https://github.com/DiamondToken/dotfiles.git      "/home/$USER/dotfiles"
git clone https://github.com/DiamondToken/st-diamond.git    "/home/$USER/st"
git clone https://github.com/DiamondToken/dmenu-diamond.git "/home/$USER/dmenu"


cd /home/$USER/dotfiles/

sudo ./stowing.sh root
sudo su -u $USER ./stowing.sh stash


# sudo ./home/$USER/dotfiles/stowing.sh root
#      ./home/$USER/dotfiles/stowing.sh stash
