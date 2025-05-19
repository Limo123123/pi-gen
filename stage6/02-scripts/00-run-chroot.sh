#!/bin/bash
set -e

echo "Starte LimOS Anpassungen..."

# 1. Plymouth Theme aktivieren
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/limos/limos.plymouth 100
update-alternatives --set default.plymouth /usr/share/plymouth/themes/limos/limos.plymouth
update-initramfs -u

# 2. Wallpaper als Standard setzen für KDE
mkdir -p /etc/skel/.config
cat > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc <<EOF
[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/limo.png
EOF

mkdir -p /home/pi/.config
cp /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc /home/pi/.config/
chown -R pi:pi /home/pi/.config

echo "LimOS Anpassungen abgeschlossen."

