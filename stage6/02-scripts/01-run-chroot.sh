#!/bin/bash
set -e

echo "==> Stage 6 – LimoOS Systemkonfiguration (im Chroot)"

# Locale sicherstellen
echo "LANG=de_DE.UTF-8" > /etc/default/locale
dpkg-reconfigure --frontend noninteractive locales

# Timezone setzen
ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# LimoOS Boot-MOTD
cat << "EOF" > /etc/motd
  _      _            ____   _____
 | |    (_)          / __ \ / ____|
 | |     _ _ __ ___ | |  | | (___
 | |    | | '_ ` _ \| |  | |\___ \
 | |____| | | | | | | |__| |____) |
 |______|_|_| |_| |_|\____/|_____/

Willkommen zu LimoOS!
EOF

# os-release überschreiben
cat << EOF > /etc/os-release
NAME="LimOS"
VERSION="1.0 (nova)"
ID=limos
PRETTY_NAME="LimOS 1.0 Nova (Wayland)"
VERSION_CODENAME=nova
EOF

# APT-Quelle einrichten und Update
echo "deb [trusted=yes] https://raw.githubusercontent.com/Limo123123/aptrepo/main/ nova main" \
    > /etc/apt/sources.list.d/limoos.list
apt-get update

# Hostname setzen
echo "limos" > /etc/hostname

# /etc/issue anpassen
cat << EOF > /etc/issue
LimOS 1.0 Nova \n \l
EOF

# lsb-release
cat <<EOF > /etc/lsb-release
DISTRIB_ID=LimOS
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=nova
DISTRIB_DESCRIPTION="LimOS 1.0 Nova"
EOF

# SDDM aktivieren und Session setzen
# Entferne ggf. vorhandene display-manager Symlink
if [ -L /etc/systemd/system/display-manager.service ]; then
    rm /etc/systemd/system/display-manager.service
fi

# (Optional) Deaktiviere LightDM, falls installiert
systemctl try-reload-or-restart lightdm.service >/dev/null 2>&1 || true
systemctl disable lightdm.service >/dev/null 2>&1 || true

# Jetzt SDDM aktivieren
systemctl enable sddm.service

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/limos.conf <<EOF
[Autologin]
User=pi
Session=limos-plasma-wayland.desktop
EOF

# Wayland-/X11-Session‑Files
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/limos-plasma-wayland.desktop <<EOF
[Desktop Entry]
Name=LimOS Plasma (Wayland)
Comment=Plasma Desktop using Wayland on LimOS
Exec=startplasma-wayland
TryExec=startplasma-wayland
Type=Application
DesktopNames=KDE
EOF

mkdir -p /usr/share/xsessions
cat > /usr/share/xsessions/limos-plasma-x11.desktop <<EOF
[Desktop Entry]
Name=LimOS Plasma (X11)
Comment=Plasma Desktop using X11 on LimOS
Exec=startplasma-x11
TryExec=startplasma-x11
Type=Application
DesktopNames=KDE
EOF

# limos CLI-Tool ausführbar machen
chmod +x /usr/bin/limos

# Wallpaper für Benutzer pi setzen
mkdir -p /etc/skel/.config
cat > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc <<EOF
[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/limo.png
EOF
cp -r /etc/skel/.config /home/pi/
chown -R pi:pi /home/pi/.config

# Wallpaper sicher setzen mit KConfig
mkdir -p /home/pi/.config/plasma-workspace/env
cat > /home/pi/.config/plasma-workspace/env/set-wallpaper.sh <<EOF
#!/bin/sh
kwriteconfig5 --file plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 1 --group Wallpaper --group org.kde.image --group General --key Image "file:///usr/share/wallpapers/limo.png"
EOF
chmod +x /home/pi/.config/plasma-workspace/env/set-wallpaper.sh
chown -R pi:pi /home/pi/.config/plasma-workspace

echo "==> LimoOS Anpassungen im Chroot abgeschlossen."

