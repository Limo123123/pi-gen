#!/bin/bash
set -e

echo "==> Stage 6 – SDDM & Sessions im Chroot"

# SDDM aktivieren
systemctl enable sddm.service

# SDDM Standard-Session auf LimOS Plasma Wayland setzen
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/limos.conf <<EOF
[Autologin]
User=pi
Session=limos-plasma-wayland.desktop
EOF

# Wayland Session-File erstellen
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

# X11 Session-File als Fallback
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

echo "==> SDDM & Sessions konfiguriert."

echo "==> Stage 6 – Plymouth Theme aktivieren und Initramfs rebuilden"

# Setze LimOS als Standard-Theme und baue Initrd neu
plymouth-set-default-theme limos --rebuild-initrd

# (Optional, falls --rebuild-initrd nicht verfügbar)
# update-initramfs -u

echo "==> Plymouth Initramfs aktualisiert."

