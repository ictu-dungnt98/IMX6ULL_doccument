#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# PATH CONFIG
# =========================================================

HOME_DIR="${HOME}"

KERNEL_SRC="${HOME_DIR}/work"
ROOTFS="${KERNEL_SRC}/rootfs"
FLASH_DIR="${HOME_DIR}/flash"


UBOOT_VER="2022.04"
UBOOT_SRC="${HOME_DIR}/u-boot-${UBOOT_VER}"

MOSQ_VER="1.6.15"
MOSQ_SRC="${HOME_DIR}/mosquitto-${MOSQ_VER}"

APP_SRC_DIR="${HOME_DIR}/source_app"

TOOLCHAIN="/opt/fsl-imx-x11/4.1.15-2.0.0/environment-setup-cortexa7hf-neon-poky-linux-gnueabi"

# =========================================================
# HELPER
# =========================================================

log() {
    echo
    echo "========================================================="
    echo "$1"
    echo "========================================================="
}

# =========================================================
# INSTALL PACKAGES
# =========================================================

log "INSTALL BUILD PACKAGES"

sudo apt update

sudo apt install -y \
    libncurses5-dev \
    libncursesw5-dev \
    lzop \
    bc \
    flex \
    bison \
    libssl-dev \
    fakeroot \
    device-tree-compiler \
    u-boot-tools \
    parted \
    dosfstools \
    wget \
    libgnutls28-dev

# =========================================================
# LOAD TOOLCHAIN
# =========================================================

log "LOAD TOOLCHAIN"

source "${TOOLCHAIN}"

# =========================================================
# BUILD KERNEL
# =========================================================

cd "${KERNEL_SRC}"

log "CLEAN KERNEL"

make mrproper

log "LOAD DEFAULT CONFIG"

make imx6ull_defconfig

log "SET CUSTOM VERSION"

scripts/config --set-str LOCALVERSION "-quanghaHNN"

# =========================================================
# WIFI CONFIG
# =========================================================

log "ENABLE WIFI"

scripts/config --enable WLAN
scripts/config --enable WIRELESS
scripts/config --enable CFG80211
scripts/config --enable MAC80211
scripts/config --enable RFKILL
scripts/config --enable FW_LOADER

scripts/config --enable CFG80211_WEXT
scripts/config --enable WEXT_CORE
scripts/config --enable WEXT_PROC
scripts/config --enable WEXT_PRIV

scripts/config --module RTL8XXXU
scripts/config --enable RTL8XXXU_UNTESTED

# =========================================================
# USB CONFIG
# =========================================================

log "ENABLE USB"

scripts/config --enable USB_SUPPORT
scripts/config --enable USB
scripts/config --enable USB_COMMON
scripts/config --enable USB_HID

# =========================================================
# REMOVE UNUSED
# =========================================================

log "DISABLE UNUSED DRIVERS"

scripts/config --disable MEDIA_SUPPORT
scripts/config --disable VIDEO_DEV
scripts/config --disable USB_VIDEO_CLASS
scripts/config --disable SND_USB_AUDIO

# =========================================================
# FINALIZE CONFIG
# =========================================================

log "FINALIZE CONFIG"

make olddefconfig

# =========================================================
# BUILD
# =========================================================

log "BUILD KERNEL"

make -j"$(nproc)" zImage dtbs modules

# =========================================================
# ROOTFS
# =========================================================

log "PREPARE ROOTFS"

mkdir -p "${ROOTFS}"

sudo rm -rf "${ROOTFS:?}"/*

cd "${ROOTFS}"

wget -O rootfs-console.tar.bz2 \
https://github.com/dinhquanghaICTU/IMX6ULL_doccument/releases/download/v1.0/rootfs-console.tar.bz2

tar xvf rootfs-console.tar.bz2

# =========================================================
# INSTALL MODULES
# =========================================================

log "INSTALL MODULES"

cd "${KERNEL_SRC}"

make modules_install INSTALL_MOD_PATH="${ROOTFS}"

# =========================================================
# COPY WIFI FIRMWARE
# =========================================================

log "COPY WIFI FIRMWARE"

mkdir -p "${ROOTFS}/lib/firmware/rtlwifi"

sudo cp -rv /lib/firmware/rtlwifi/* \
"${ROOTFS}/lib/firmware/rtlwifi/" || true

# =========================================================
# VERIFY RTL
# =========================================================

log "VERIFY RTL MODULE"

find "${ROOTFS}/lib/modules" | grep rtl8 || true

# =========================================================
# WIFI CONFIG
# =========================================================

log "CREATE WPA CONFIG"

mkdir -p "${ROOTFS}/etc/wpa_supplicant"

cat > "${ROOTFS}/etc/wpa_supplicant/wpa_supplicant.conf" <<'EOF'
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    ssid="SALE"
    psk="66668888"
}
EOF

# =========================================================
# NETWORK INTERFACES
# =========================================================

log "CREATE NETWORK INTERFACES"

cat > "${ROOTFS}/etc/network/interfaces" <<'EOF'
auto lo
iface lo inet loopback

auto wlan0
iface wlan0 inet dhcp
wpa-driver wext
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

auto eth0
iface eth0 inet static
address 192.168.0.232
netmask 255.255.255.0
broadcast 192.168.0.255

auto usb0
iface usb0 inet static
address 192.168.7.2
netmask 255.255.255.0
EOF

# =========================================================
# BUILD MOSQUITTO
# =========================================================

log "BUILD MOSQUITTO"

cd "${HOME_DIR}"

wget https://mosquitto.org/files/source/mosquitto-${MOSQ_VER}.tar.gz

tar xvf mosquitto-${MOSQ_VER}.tar.gz

cd "${MOSQ_SRC}"

source "${TOOLCHAIN}"

make clean || true

unset CROSS_COMPILE

make \
    CC="${CC}" \
    WITH_TLS=no \
    WITH_TLS_PSK=no \
    WITH_SRV=no \
    WITH_WEBSOCKETS=no \
    WITH_DOCS=no \
    WITH_SHARED_LIBRARIES=yes \
    WITH_STATIC_LIBRARIES=yes \
    prefix=/usr \
    -j"$(nproc)"

# =========================================================
# INSTALL MOSQUITTO
# =========================================================

log "INSTALL MOSQUITTO"

mkdir -p "${ROOTFS}/usr/bin"
mkdir -p "${ROOTFS}/usr/sbin"
mkdir -p "${ROOTFS}/usr/lib"

cp src/mosquitto "${ROOTFS}/usr/sbin/"
cp client/mosquitto_pub "${ROOTFS}/usr/bin/"
cp client/mosquitto_sub "${ROOTFS}/usr/bin/"
cp lib/libmosquitto.so.1 "${ROOTFS}/usr/lib/"

cd "${ROOTFS}/usr/lib"

ln -sf libmosquitto.so.1 libmosquitto.so

# =========================================================
# MOSQUITTO CONFIG
# =========================================================

log "CREATE MOSQUITTO CONFIG"

mkdir -p "${ROOTFS}/etc/mosquitto"

cat > "${ROOTFS}/etc/mosquitto/mosquitto.conf" <<'EOF'
listener 1883 0.0.0.0
allow_anonymous true
persistence false
log_dest stdout
EOF

# =========================================================
# BUILD MQTT APP
# =========================================================
log "DOWNLOAD MQTT APP"

mkdir -p "${APP_SRC_DIR}"
cd "${APP_SRC_DIR}"

APP_URL="https://raw.githubusercontent.com/dinhquanghaICTU/HNN_OKM6ULL_OTA/main/build/mqtt_led_app"

log "Downloading mqtt_led_app from GitHub..."

set +e

wget --no-check-certificate --tries=3 --timeout=15 \
     -q -O mqtt_led_app "$APP_URL"
WGET_STATUS=$?

if [ $WGET_STATUS -ne 0 ] || [ ! -s mqtt_led_app ]; then
    log_warn "wget failed (code=$WGET_STATUS), trying curl..."
    curl -fsSL --retry 3 --connect-timeout 15 \
         -o mqtt_led_app "$APP_URL"
    CURL_STATUS=$?
    if [ $CURL_STATUS -ne 0 ] || [ ! -s mqtt_led_app ]; then
        log_warn "Failed to download mqtt_led_app -> abort"
        exit 1
    fi
    log "Downloaded via curl"
else
    log "Downloaded mqtt_led_app successfully"
fi

set -e

chmod +x mqtt_led_app

mkdir -p "${ROOTFS}/usr/bin"
cp mqtt_led_app "${ROOTFS}/usr/bin/"
log "Copied mqtt_led_app to rootfs"
log "=================================================================="

# =========================================================
# BUILD U-BOOT FW_PRINTENV / FW_SETENV FOR ARM
# =========================================================

log "BUILD U-BOOT FW_PRINTENV FOR ARM"

UBOOT_VER="2022.04"
UBOOT_TARBALL="${HOME_DIR}/u-boot-${UBOOT_VER}.tar.bz2"
UBOOT_SRC="${HOME_DIR}/u-boot-${UBOOT_VER}"

cd "${HOME_DIR}"

if [ ! -f "${UBOOT_TARBALL}" ]; then
    wget -O "${UBOOT_TARBALL}" \
        "https://ftp.denx.de/pub/u-boot/u-boot-${UBOOT_VER}.tar.bz2"
fi

rm -rf "${UBOOT_SRC}"
tar xjf "${UBOOT_TARBALL}"

source "${TOOLCHAIN}"

cd "${UBOOT_SRC}"

${CC} \
    -Iinclude \
    -Itools/env \
    -Itools \
    -DUSE_HOSTCC \
    -o fw_printenv \
    tools/env/fw_env_main.c \
    tools/env/fw_env.c \
    tools/env/env_attr.c \
    tools/env/env_flags.c \
    tools/env/crc32.c \
    tools/env/ctype.c \
    tools/env/linux_string.c

mkdir -p "${ROOTFS}/usr/bin"
mkdir -p "${ROOTFS}/etc"

cp fw_printenv "${ROOTFS}/usr/bin/fw_printenv"

cd "${ROOTFS}/usr/bin"
ln -sf fw_printenv fw_setenv
chmod +x fw_printenv

cat > "${ROOTFS}/etc/fw_env.config" <<'EOF'
/dev/mmcblk1 0x400000 0x2000
EOF

file "${ROOTFS}/usr/bin/fw_printenv"

# =========================================================
# OTA CONFIRM BOOT
# =========================================================

log "CREATE OTA CONFIRM BOOT SCRIPT"

cat > "${ROOTFS}/usr/bin/ota-confirm-boot.sh" <<'EOF'
#!/bin/sh

SLOT=$(sed -n 's/.*ota.slot=\([^ ]*\).*/\1/p' /proc/cmdline)

if [ -z "$SLOT" ]; then
    echo "ota-confirm: no ota.slot"
    exit 0
fi

echo "ota-confirm: slot=$SLOT"

fw_setenv boot_slot "$SLOT"
fw_setenv upgrade_available 0
fw_setenv bootcount 0

exit 0
EOF

chmod +x "${ROOTFS}/usr/bin/ota-confirm-boot.sh"

# =========================================================
# RC.LOCAL
# =========================================================

log "CREATE RC.LOCAL"

cat > "${ROOTFS}/etc/rc.local" <<'EOF'
#!/bin/sh

/usr/bin/ota-confirm-boot.sh &

(
while true
do
    if ! ip a show wlan0 | grep -q "inet "; then

        echo "WiFi reconnect"

        killall wpa_supplicant 2>/dev/null

        ifconfig wlan0 up

        wpa_supplicant -B \
            -i wlan0 \
            -c /etc/wpa_supplicant/wpa_supplicant.conf

        sleep 5

        udhcpc -i wlan0 -n -q
    fi

    sleep 10
done
) &

(
while true
do
    if ip a show wlan0 | grep -q "inet "; then

        echo "WiFi ready -> start mqtt_led_app"

        /usr/bin/mqtt_led_app

        echo "mqtt_led_app exited -> restart"
    else
        echo "Waiting WiFi..."
    fi

    sleep 5
done
) &

exit 0
EOF

chmod +x "${ROOTFS}/etc/rc.local"

# =========================================================
# REPACK ROOTFS
# =========================================================

log "REPACK ROOTFS"

cd "${ROOTFS}"

rm -f rootfs-console.tar.bz2

fakeroot tar cvjf rootfs-console.tar.bz2 *

# =========================================================
# PREPARE FLASH
# =========================================================

log "PREPARE FLASH"

mkdir -p "${FLASH_DIR}"

cp "${ROOTFS}/rootfs-console.tar.bz2" "${FLASH_DIR}/"

cp "${KERNEL_SRC}/arch/arm/boot/zImage" "${FLASH_DIR}/"

cp "${KERNEL_SRC}/arch/arm/boot/dts/okmx6ull-s-emmc.dtb" \
"${FLASH_DIR}/"

# =========================================================
# DONE
# =========================================================

log "DONE"

ls -lh "${FLASH_DIR}"

echo "================= create wic script ================="

cd "$FLASH_DIR"

cat > create_rootfs_wifi_wic.sh <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

IMG="rootfs_wifi.wic"

ROOTFS="rootfs-console.tar.bz2"

KERNEL="zImage"

DTB="okmx6ull-s-emmc.dtb"

BOOT_MNT="/mnt/wic_boot"
ROOT_A_MNT="/mnt/wic_root_a"
ROOT_B_MNT="/mnt/wic_root_b"
DATA_MNT="/mnt/wic_data"

cleanup() {

    sync || true

    sudo umount "$BOOT_MNT" 2>/dev/null || true
    sudo umount "$ROOT_A_MNT" 2>/dev/null || true
    sudo umount "$ROOT_B_MNT" 2>/dev/null || true
    sudo umount "$DATA_MNT" 2>/dev/null || true

    if [ -n "${LOOP_DEV:-}" ]; then
        sudo losetup -d "$LOOP_DEV" || true
    fi
}

trap cleanup EXIT

echo "================= create image ================="

rm -f "$IMG"

# 4GB image:
# p1 = BOOT     256MB
# p2 = rootfs_A ~1.5GB
# p3 = rootfs_B ~1.5GB
# p4 = data     remaining
dd if=/dev/zero of="$IMG" bs=1M count=4096

echo "================= create partition ================="

parted -s "$IMG" mklabel msdos

parted -s "$IMG" mkpart primary fat32 8MiB 264MiB
parted -s "$IMG" set 1 boot on

parted -s "$IMG" mkpart primary ext4 264MiB 1800MiB
parted -s "$IMG" mkpart primary ext4 1800MiB 3336MiB
parted -s "$IMG" mkpart primary ext4 3336MiB 100%

echo "================= attach loop device ================="

LOOP_DEV=$(sudo losetup --find --show -P "$IMG")

echo "LOOP_DEV = $LOOP_DEV"

echo "================= format partitions ================="

sudo mkfs.vfat -F 32 -n BOOT "${LOOP_DEV}p1"

sudo mkfs.ext4 -F -L rootfs_A "${LOOP_DEV}p2"
sudo mkfs.ext4 -F -L rootfs_B "${LOOP_DEV}p3"
sudo mkfs.ext4 -F -L data "${LOOP_DEV}p4"

echo "================= mount partitions ================="

sudo mkdir -p "$BOOT_MNT"
sudo mkdir -p "$ROOT_A_MNT"
sudo mkdir -p "$ROOT_B_MNT"
sudo mkdir -p "$DATA_MNT"

sudo mount "${LOOP_DEV}p1" "$BOOT_MNT"
sudo mount "${LOOP_DEV}p2" "$ROOT_A_MNT"
sudo mount "${LOOP_DEV}p3" "$ROOT_B_MNT"
sudo mount "${LOOP_DEV}p4" "$DATA_MNT"

echo "================= copy boot files A/B ================="

sudo cp "$KERNEL" "$BOOT_MNT/zImage_A"
sudo cp "$KERNEL" "$BOOT_MNT/zImage_B"

sudo cp "$DTB" "$BOOT_MNT/okmx6ull-s-emmc_A.dtb"
sudo cp "$DTB" "$BOOT_MNT/okmx6ull-s-emmc_B.dtb"

# Optional compatibility names for old bootcmd
sudo cp "$KERNEL" "$BOOT_MNT/zImage"
sudo cp "$DTB" "$BOOT_MNT/okmx6ull-s-emmc.dtb"

echo "================= extract rootfs A/B ================="

sudo tar --numeric-owner -xpf "$ROOTFS" -C "$ROOT_A_MNT"
sudo tar --numeric-owner -xpf "$ROOTFS" -C "$ROOT_B_MNT"

echo "================= create data dirs ================="

sudo mkdir -p "$DATA_MNT/ota"
sudo mkdir -p "$DATA_MNT/log"
sudo mkdir -p "$DATA_MNT/app"

sync

echo "================= verify partitions ================="

sudo fdisk -l "$LOOP_DEV" || true

echo "================= verify boot files ================="

ls -lh "$BOOT_MNT"

echo "================= WIC DONE ================="

ls -lh "$IMG"
EOF

chmod +x create_rootfs_wifi_wic.sh

echo "================= build wic ================="

sudo ./create_rootfs_wifi_wic.sh

echo "================= verify ================="

ls -lh "$FLASH_DIR"

echo "================= DONE ================="