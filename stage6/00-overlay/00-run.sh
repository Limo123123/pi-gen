#!/bin/bash
set -e

echo "[INFO] Kopiere Overlay-Dateien"
rsync -a files/ "${ROOTFS_DIR}/"

ls -la "${ROOTFS_DIR}/usr/share/plymouth/themes/limos"
ls -la "${ROOTFS_DIR}/usr/share/plymouth/themes/"
ls -la "${ROOTFS_DIR}/usr/share/plymouth"
ls -la "${ROOTFS_DIR}/usr/share/"
