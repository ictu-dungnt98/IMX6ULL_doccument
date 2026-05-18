#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# PATH CONFIG
# =========================================================

HOME_DIR="${HOME}"

KERNEL_SRC="${HOME_DIR}/work"
ROOTFS="${KERNEL_SRC}/rootfs"
FLASH_DIR="${HOME_DIR}/flash"

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
    wget

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

scripts/config --set-str LOCALVERSION "-quanghadev"

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

log "BUILD MQTT APP"

mkdir -p "${APP_SRC_DIR}"

cd "${APP_SRC_DIR}"

log "BUILD MQTT APP"

mkdir -p "${APP_SRC_DIR}"

cd "${APP_SRC_DIR}"

cat > app.c <<'EOF'
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <unistd.h>

#define BROKER_IP   "192.168.1.66"
#define BROKER_PORT 1883
#define CLIENT_ID   "imx6ull_led1"
#define TOPIC       "test/topic"

#define LED_TRIGGER    "/sys/class/leds/led1/trigger"
#define LED_BRIGHTNESS "/sys/class/leds/led1/brightness"

#define BUF_SIZE 1024

static int put_remaining_length(unsigned char *buf, int len)
{
    int i = 0;

    do {
        unsigned char encoded = len % 128;
        len /= 128;

        if (len > 0)
            encoded |= 128;

        buf[i++] = encoded;

    } while (len > 0);

    return i;
}

static int put_string(unsigned char *buf, const char *s)
{
    int len = strlen(s);

    buf[0] = (unsigned char)(len >> 8);
    buf[1] = (unsigned char)(len & 0xff);

    memcpy(buf + 2, s, len);

    return len + 2;
}

static int read_exact(int fd, unsigned char *buf, int len)
{
    int total = 0;

    while (total < len) {

        int n = read(fd, buf + total, len - total);

        if (n <= 0)
            return -1;

        total += n;
    }

    return 0;
}

static int read_remaining_length(int fd, int *out_len)
{
    int multiplier = 1;
    int value = 0;

    unsigned char encoded;

    do {

        if (read_exact(fd, &encoded, 1) < 0)
            return -1;

        value += (encoded & 127) * multiplier;

        multiplier *= 128;

        if (multiplier > 128 * 128 * 128)
            return -1;

    } while (encoded & 128);

    *out_len = value;

    return 0;
}

static int mqtt_read_packet(
    int fd,
    unsigned char *type,
    unsigned char *buf,
    int *len)
{
    if (read_exact(fd, type, 1) < 0)
        return -1;

    if (read_remaining_length(fd, len) < 0)
        return -1;

    if (*len > BUF_SIZE)
        return -1;

    if (read_exact(fd, buf, *len) < 0)
        return -1;

    return 0;
}

static int write_text_file(const char *path, const char *value)
{
    int fd;
    ssize_t written;
    size_t len;

    fd = open(path, O_WRONLY);

    if (fd < 0) {
        perror(path);
        return -1;
    }

    len = strlen(value);

    written = write(fd, value, len);

    close(fd);

    if (written != (ssize_t)len) {
        perror("write");
        return -1;
    }

    return 0;
}

static int read_text_file(
    const char *path,
    char *buf,
    size_t size)
{
    int fd;
    ssize_t n;

    fd = open(path, O_RDONLY);

    if (fd < 0) {
        perror(path);
        return -1;
    }

    n = read(fd, buf, size - 1);

    close(fd);

    if (n < 0) {
        perror("read");
        return -1;
    }

    buf[n] = '\0';

    return 0;
}

static int led_manual_mode(void)
{
    return write_text_file(
        LED_TRIGGER,
        "none\n");
}

static int led_set(int on)
{
    if (led_manual_mode() < 0)
        return -1;

    return write_text_file(
        LED_BRIGHTNESS,
        on ? "1\n" : "0\n");
}

static int led_toggle(void)
{
    char buf[32];

    int is_on;

    if (read_text_file(
            LED_BRIGHTNESS,
            buf,
            sizeof(buf)) < 0)
        return -1;

    is_on = atoi(buf) > 0;

    return led_set(!is_on);
}

static int led_blink(void)
{
    return write_text_file(
        LED_TRIGGER,
        "heartbeat\n");
}

static void trim_message(char *s)
{
    size_t len;

    while (*s == ' ' ||
           *s == '\t' ||
           *s == '\r' ||
           *s == '\n')
    {
        memmove(s, s + 1, strlen(s));
    }

    len = strlen(s);

    while (len > 0 &&
          (s[len - 1] == ' ' ||
           s[len - 1] == '\t' ||
           s[len - 1] == '\r' ||
           s[len - 1] == '\n'))
    {
        s[len - 1] = '\0';
        len--;
    }
}

static void lowercase(char *s)
{
    while (*s) {

        if (*s >= 'A' && *s <= 'Z')
            *s = *s - 'A' + 'a';

        s++;
    }
}

static void handle_command(
    const char *topic,
    const char *msg,
    int msg_len)
{
    char cmd[256];
    char state[64];

    int copy_len = msg_len;

    if (copy_len >= (int)sizeof(cmd))
        copy_len = sizeof(cmd) - 1;

    memcpy(cmd, msg, copy_len);

    cmd[copy_len] = '\0';

    trim_message(cmd);

    lowercase(cmd);

    printf(
        "MQTT message on topic '%s': %s\n",
        topic,
        cmd);

    if (strcmp(cmd, "led on") == 0 ||
        strcmp(cmd, "on") == 0)
    {
        if (led_set(1) == 0)
            printf("LED1: on\n");
    }
    else if (strcmp(cmd, "led off") == 0 ||
             strcmp(cmd, "off") == 0)
    {
        if (led_set(0) == 0)
            printf("LED1: off\n");
    }
    else if (strcmp(cmd, "led toggle") == 0 ||
             strcmp(cmd, "toggle") == 0)
    {
        if (led_toggle() == 0)
            printf("LED1: toggled\n");
    }
    else if (strcmp(cmd, "led blink") == 0 ||
             strcmp(cmd, "blink") == 0)
    {
        if (led_blink() == 0)
            printf("LED1: heartbeat\n");
    }
    else if (strcmp(cmd, "status") == 0)
    {
        if (read_text_file(
                LED_BRIGHTNESS,
                state,
                sizeof(state)) == 0)
        {
            printf(
                "LED1 brightness: %s",
                state);
        }
    }
    else {
        printf(
            "Unknown command: %s\n",
            cmd);
    }

    fflush(stdout);
}

static int tcp_connect(void)
{
    int sock;

    struct sockaddr_in addr;

    sock = socket(AF_INET, SOCK_STREAM, 0);

    if (sock < 0) {
        perror("socket");
        return -1;
    }

    memset(&addr, 0, sizeof(addr));

    addr.sin_family = AF_INET;

    addr.sin_port = htons(BROKER_PORT);

    if (inet_pton(
            AF_INET,
            BROKER_IP,
            &addr.sin_addr) != 1)
    {
        perror("inet_pton");
        close(sock);
        return -1;
    }

    if (connect(
            sock,
            (struct sockaddr *)&addr,
            sizeof(addr)) < 0)
    {
        perror("connect");
        close(sock);
        return -1;
    }

    return sock;
}

static int mqtt_connect(int sock)
{
    unsigned char pkt[BUF_SIZE];
    unsigned char type;
    unsigned char payload[BUF_SIZE];

    int pos = 0;
    int rem_len;
    int len;

    pkt[pos++] = 0x10;

    rem_len = 10 + 2 + strlen(CLIENT_ID);

    pos += put_remaining_length(
        pkt + pos,
        rem_len);

    pos += put_string(
        pkt + pos,
        "MQTT");

    pkt[pos++] = 4;
    pkt[pos++] = 2;
    pkt[pos++] = 0;
    pkt[pos++] = 60;

    pos += put_string(
        pkt + pos,
        CLIENT_ID);

    if (write(sock, pkt, pos) != pos)
        return -1;

    if (mqtt_read_packet(
            sock,
            &type,
            payload,
            &len) < 0)
    {
        return -1;
    }

    if (type != 0x20 ||
        len < 2 ||
        payload[1] != 0x00)
    {
        printf("MQTT CONNACK failed\n");
        return -1;
    }

    return 0;
}

static int mqtt_subscribe(int sock)
{
    unsigned char pkt[BUF_SIZE];
    unsigned char type;
    unsigned char payload[BUF_SIZE];

    int pos = 0;
    int rem_len;
    int len;

    pkt[pos++] = 0x82;

    rem_len =
        2 +
        2 +
        strlen(TOPIC) +
        1;

    pos += put_remaining_length(
        pkt + pos,
        rem_len);

    pkt[pos++] = 0;
    pkt[pos++] = 1;

    pos += put_string(
        pkt + pos,
        TOPIC);

    pkt[pos++] = 0;

    if (write(sock, pkt, pos) != pos)
        return -1;

    if (mqtt_read_packet(
            sock,
            &type,
            payload,
            &len) < 0)
    {
        return -1;
    }

    if (type != 0x90) {
        printf("MQTT SUBACK failed\n");
        return -1;
    }

    return 0;
}

static void handle_publish(
    unsigned char fixed_type,
    unsigned char *buf,
    int len)
{
    char topic[128];

    int topic_len;
    int pos;
    int payload_len;
    int qos;

    if (len < 2)
        return;

    topic_len =
        (buf[0] << 8) |
        buf[1];

    pos = 2 + topic_len;

    if (topic_len >= (int)sizeof(topic) ||
        pos > len)
    {
        return;
    }

    memcpy(
        topic,
        buf + 2,
        topic_len);

    topic[topic_len] = '\0';

    qos = (fixed_type >> 1) & 0x03;

    if (qos > 0)
        pos += 2;

    if (pos > len)
        return;

    payload_len = len - pos;

    handle_command(
        topic,
        (const char *)(buf + pos),
        payload_len);
}

static int mqtt_loop(int sock)
{
    unsigned char type;
    unsigned char buf[BUF_SIZE];

    int len;

    while (1) {

        fd_set rfds;

        struct timeval tv;

        int ret;

        FD_ZERO(&rfds);

        FD_SET(sock, &rfds);

        tv.tv_sec = 30;
        tv.tv_usec = 0;

        ret = select(
            sock + 1,
            &rfds,
            NULL,
            NULL,
            &tv);

        if (ret < 0)
            return -1;

        if (ret == 0) {

            unsigned char pingreq[] = {
                0xC0,
                0x00
            };

            if (write(
                    sock,
                    pingreq,
                    sizeof(pingreq)) != sizeof(pingreq))
            {
                return -1;
            }

            continue;
        }

        if (mqtt_read_packet(
                sock,
                &type,
                buf,
                &len) < 0)
        {
            return -1;
        }

        if ((type & 0xF0) == 0x30)
            handle_publish(type, buf, len);
    }
}

int main(void)
{
    led_manual_mode();

    while (1) {

        int sock;

        printf(
            "Connecting to MQTT broker %s:%d...\n",
            BROKER_IP,
            BROKER_PORT);

        fflush(stdout);

        sock = tcp_connect();

        if (sock < 0) {
            sleep(2);
            continue;
        }

        if (mqtt_connect(sock) < 0) {

            close(sock);

            sleep(2);

            continue;
        }

        if (mqtt_subscribe(sock) < 0) {

            close(sock);

            sleep(2);

            continue;
        }

        printf(
            "Subscribed to topic: %s\n",
            TOPIC);

        fflush(stdout);

        mqtt_loop(sock);

        printf(
            "MQTT disconnected, reconnecting...\n");

        close(sock);

        sleep(2);
    }

    return 0;
}
EOF

source "${TOOLCHAIN}"

${CC} app.c -o mqtt_led_app

mkdir -p "${ROOTFS}/usr/bin"

cp mqtt_led_app "${ROOTFS}/usr/bin/"

# =========================================================
# RC.LOCAL
# =========================================================

log "CREATE RC.LOCAL"

cat > "${ROOTFS}/etc/rc.local" <<'EOF'
#!/bin/sh

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
ROOT_MNT="/mnt/wic_root"

cleanup() {

    sync || true

    sudo umount "$BOOT_MNT" 2>/dev/null || true
    sudo umount "$ROOT_MNT" 2>/dev/null || true

    if [ -n "${LOOP_DEV:-}" ]; then
        sudo losetup -d "$LOOP_DEV" || true
    fi
}

trap cleanup EXIT

echo "================= create image ================="

rm -f "$IMG"

dd if=/dev/zero of="$IMG" bs=1M count=2048

echo "================= create partition ================="

parted -s "$IMG" mklabel msdos

parted -s "$IMG" mkpart primary fat32 8MiB 128MiB

parted -s "$IMG" set 1 boot on

parted -s "$IMG" mkpart primary ext4 128MiB 100%

echo "================= attach loop device ================="

LOOP_DEV=$(sudo losetup --find --show -P "$IMG")

echo "LOOP_DEV = $LOOP_DEV"

echo "================= format partitions ================="

sudo mkfs.vfat -F 32 "${LOOP_DEV}p1"

sudo mkfs.ext4 -F "${LOOP_DEV}p2"

echo "================= mount partitions ================="

sudo mkdir -p "$BOOT_MNT"
sudo mkdir -p "$ROOT_MNT"

sudo mount "${LOOP_DEV}p1" "$BOOT_MNT"

sudo mount "${LOOP_DEV}p2" "$ROOT_MNT"

echo "================= copy boot files ================="

sudo cp "$KERNEL" "$BOOT_MNT/"

sudo cp "$DTB" "$BOOT_MNT/"

echo "================= extract rootfs ================="

sudo tar --numeric-owner -xpf "$ROOTFS" -C "$ROOT_MNT"

sync

echo "================= WIC DONE ================="

ls -lh "$IMG"
EOF

chmod +x create_rootfs_wifi_wic.sh

echo "================= build wic ================="

sudo ./create_rootfs_wifi_wic.sh

echo "================= verify ================="

ls -lh "$FLASH_DIR"

echo "================= DONE ================="