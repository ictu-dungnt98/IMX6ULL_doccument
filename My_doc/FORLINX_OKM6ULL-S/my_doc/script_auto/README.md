# Giải thích script build Kernel + RootFS + OTA A/B cho OKMX6ULL

Tài liệu này giải thích toàn bộ script build hiện tại: script dùng để build kernel, chuẩn bị rootfs, thêm WiFi/MQTT/libubootenv, tạo `boot.scr`, tạo image `.wic` dạng A/B, và chuẩn bị file để flash bằng UUU.

---

## 1. Mục tiêu tổng thể của script

Script này làm các việc chính:

1. Cài package build cần thiết trên máy host.
2. Load cross-toolchain của NXP/Freescale.
3. Build Linux kernel `zImage`, device tree và modules.
4. Tải và bung rootfs console.
5. Install kernel modules vào rootfs.
6. Thêm WiFi firmware và cấu hình mạng.
7. Build Mosquitto/MQTT client cho target ARM.
8. Cài app `mqtt_led_app` vào rootfs.
9. Build `libubootenv`, `fw_printenv`, `fw_setenv` để Linux có thể đọc/ghi U-Boot env.
10. Tạo script `ota-confirm-boot.sh` để confirm slot boot OK.
11. Tạo `rc.local` để chạy WiFi reconnect và app MQTT.
12. Repack rootfs thành `rootfs-console.tar.bz2`.
13. Copy kernel, dtb, rootfs vào thư mục flash.
14. Tạo `boot.cmd`, compile thành `boot.scr`.
15. Tạo file `rootfs_wifi.wic` gồm boot partition + rootfs A/B + data.

Luồng cuối cùng sau khi flash:

```text
ROM i.MX6ULL
→ U-Boot
→ đọc boot.scr từ FAT boot partition
→ chọn slot A hoặc B
→ load zImage_A/B + dtb_A/B
→ truyền root=/dev/mmcblk1p2 hoặc /dev/mmcblk1p3
→ Linux boot
→ ota-confirm-boot.sh confirm slot
→ mqtt_led_app nhận lệnh OTA qua MQTT
```

---

## 2. Biến cấu hình đường dẫn

Đầu script có nhóm biến:

```bash
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
```

Ý nghĩa:

| Biến | Ý nghĩa |
|---|---|
| `HOME_DIR` | Thư mục home của user host |
| `KERNEL_SRC` | Source kernel đang build |
| `ROOTFS` | Thư mục rootfs tạm để chỉnh sửa |
| `FLASH_DIR` | Thư mục chứa file cuối để flash |
| `MOSQ_VER` | Version Mosquitto |
| `MOSQ_SRC` | Source Mosquitto sau khi giải nén |
| `APP_SRC_DIR` | Nơi tải/copy app MQTT |
| `TOOLCHAIN` | Script environment setup của cross-toolchain ARM |

`TOOLCHAIN` rất quan trọng. Khi `source` file này, host sẽ có các biến như `CC`, `CXX`, `TARGET_PREFIX`, `SDKTARGETSYSROOT` để build binary chạy trên ARM Cortex-A7 của i.MX6ULL.

---

## 3. Hàm log

```bash
log() {
    echo
    echo "========================================================="
    echo "$1"
    echo "========================================================="
}
```

Hàm này chỉ để in tiêu đề từng bước, giúp log dễ đọc.

Ví dụ:

```bash
log "BUILD KERNEL"
```

sẽ in ra một block tiêu đề rõ ràng.

---

## 4. Cài package build trên host

Script chạy:

```bash
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
    libgnutls28-dev \
    cmake
```

Các package chính:

| Package | Dùng để làm gì |
|---|---|
| `libncurses*-dev` | Kernel menu/config |
| `lzop` | Nén kernel/rootfs |
| `bc`, `flex`, `bison` | Build kernel |
| `libssl-dev` | Build U-Boot/kernel tools |
| `fakeroot` | Đóng gói rootfs giữ permission |
| `device-tree-compiler` | Build `.dtb` |
| `u-boot-tools` | Có lệnh `mkimage` để tạo `boot.scr` |
| `parted`, `dosfstools` | Tạo partition và FAT boot partition |
| `cmake` | Build libubootenv |

---

## 5. Load toolchain

```bash
source "${TOOLCHAIN}"
```

Sau dòng này, môi trường build chuyển sang cross-compile cho target ARM.

Ví dụ compiler sẽ là dạng:

```text
arm-poky-linux-gnueabi-gcc
```

hoặc prefix tương ứng với SDK của NXP.

Không có bước này thì `make zImage`, `mosquitto`, `libubootenv` có thể build nhầm cho x86 host.

---

## 6. Build kernel

Script vào kernel source:

```bash
cd "${KERNEL_SRC}"
make mrproper
make imx6ull_defconfig
scripts/config --set-str LOCALVERSION "-quanghaHNN"
```

Ý nghĩa:

| Lệnh | Ý nghĩa |
|---|---|
| `make mrproper` | Clean kernel tree về trạng thái sạch |
| `make imx6ull_defconfig` | Load config mặc định cho i.MX6ULL |
| `LOCALVERSION` | Gắn hậu tố version kernel, ví dụ `4.1.15-quanghaHNN` |

---

## 7. Enable WiFi kernel config

Script bật các option WiFi:

```bash
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
```

Mục tiêu là hỗ trợ WiFi USB/Realtek.

Các phần đáng chú ý:

| Option | Ý nghĩa |
|---|---|
| `CFG80211`, `MAC80211` | Stack WiFi Linux |
| `RFKILL` | Bật/tắt radio |
| `FW_LOADER` | Load firmware từ `/lib/firmware` |
| `WEXT` | Wireless extension cũ, cần cho một số driver/tool |
| `RTL8XXXU` | Driver Realtek USB WiFi |

---

## 8. Enable USB

```bash
scripts/config --enable USB_SUPPORT
scripts/config --enable USB
scripts/config --enable USB_COMMON
scripts/config --enable USB_HID
```

Bật USB subsystem, cần cho WiFi USB, HID hoặc thiết bị USB khác.

---

## 9. Disable driver không dùng

```bash
scripts/config --disable MEDIA_SUPPORT
scripts/config --disable VIDEO_DEV
scripts/config --disable USB_VIDEO_CLASS
scripts/config --disable SND_USB_AUDIO
```

Tắt media/video/audio USB để kernel nhẹ hơn.

---

## 10. Finalize config và build kernel

```bash
make olddefconfig
make -j"$(nproc)" zImage dtbs modules
```

Ý nghĩa:

| Lệnh | Ý nghĩa |
|---|---|
| `olddefconfig` | Tự điền default cho config mới |
| `zImage` | Build kernel image |
| `dtbs` | Build device tree blob |
| `modules` | Build kernel modules |

Output quan trọng:

```text
arch/arm/boot/zImage
arch/arm/boot/dts/okmx6ull-s-emmc.dtb
```

---

## 11. Chuẩn bị rootfs

```bash
mkdir -p "${ROOTFS}"
sudo rm -rf "${ROOTFS:?}"/*
cd "${ROOTFS}"

wget -O rootfs-console.tar.bz2 \
https://github.com/dinhquanghaICTU/IMX6ULL_doccument/releases/download/v1.0/rootfs-console.tar.bz2

tar xvf rootfs-console.tar.bz2
```

Bước này tải rootfs console base rồi bung ra thư mục `${ROOTFS}`.

`"${ROOTFS:?}"` giúp tránh trường hợp biến rỗng mà xóa nhầm `/`.

---

## 12. Install kernel modules

```bash
cd "${KERNEL_SRC}"
make modules_install INSTALL_MOD_PATH="${ROOTFS}"
```

Lệnh này cài kernel modules vào:

```text
${ROOTFS}/lib/modules/<kernel-version>/
```

Nhờ vậy rootfs có module tương ứng với kernel vừa build.

---

## 13. Copy WiFi firmware

```bash
mkdir -p "${ROOTFS}/lib/firmware/rtlwifi"

sudo cp -rv /lib/firmware/rtlwifi/* \
"${ROOTFS}/lib/firmware/rtlwifi/" || true
```

Copy firmware Realtek từ host vào rootfs.

`|| true` để nếu host không có firmware thì script không dừng ngay.

---

## 14. Tạo cấu hình WiFi

Script tạo:

```text
/etc/wpa_supplicant/wpa_supplicant.conf
```

Nội dung:

```conf
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    ssid="SALE"
    psk="66668888"
}
```

Đây là WiFi mặc định board sẽ kết nối.

---

## 15. Tạo cấu hình network interfaces

Script ghi `/etc/network/interfaces`:

```conf
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
```

Ý nghĩa:

| Interface | Kiểu IP |
|---|---|
| `lo` | loopback |
| `wlan0` | DHCP qua WiFi |
| `eth0` | IP tĩnh `192.168.0.232` |
| `usb0` | IP tĩnh `192.168.7.2` |

---

## 16. Build Mosquitto cho target

Script tải Mosquitto:

```bash
wget https://mosquitto.org/files/source/mosquitto-${MOSQ_VER}.tar.gz
tar xvf mosquitto-${MOSQ_VER}.tar.gz
```

Sau đó build:

```bash
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
```

Các flag disable TLS/WebSocket/docs giúp build nhẹ hơn, phù hợp embedded.

Output copy vào rootfs:

```bash
cp src/mosquitto "${ROOTFS}/usr/sbin/"
cp client/mosquitto_pub "${ROOTFS}/usr/bin/"
cp client/mosquitto_sub "${ROOTFS}/usr/bin/"
cp lib/libmosquitto.so.1 "${ROOTFS}/usr/lib/"
ln -sf libmosquitto.so.1 libmosquitto.so
```

---

## 17. Mosquitto config trong rootfs

Script tạo:

```text
/etc/mosquitto/mosquitto.conf
```

Nội dung:

```conf
listener 1883 0.0.0.0
allow_anonymous true
persistence false
log_dest stdout
```

Ý nghĩa:

| Option | Ý nghĩa |
|---|---|
| `listener 1883 0.0.0.0` | Broker nghe port 1883 mọi interface |
| `allow_anonymous true` | Không cần user/pass |
| `persistence false` | Không lưu persistent message |
| `log_dest stdout` | Log ra stdout |

---

## 18. Download app MQTT

Script tải app:

```bash
APP_URL="https://raw.githubusercontent.com/dinhquanghaICTU/HNN_OKM6ULL_OTA/main/build/mqtt_led_app"
```

Tải bằng `wget`, nếu fail thì thử `curl`.

Sau đó:

```bash
chmod +x mqtt_led_app
cp mqtt_led_app "${ROOTFS}/usr/bin/"
```

App được đặt tại:

```text
/usr/bin/mqtt_led_app
```

Trên board, app này nhận MQTT command để điều khiển LED và OTA.

Lưu ý: trong đoạn script có gọi `log_warn`, nhưng phía trên chưa thấy định nghĩa hàm `log_warn`. Nên nếu `wget` fail thật, script có thể lỗi vì `log_warn: command not found`. Nên thêm:

```bash
log_warn() {
    echo
    echo "WARNING: $1"
}
```

---

## 19. Build libubootenv, fw_printenv, fw_setenv

Mục tiêu: Linux cần tool để đọc/ghi U-Boot environment.

Script tải:

```bash
https://github.com/sbabic/libubootenv/archive/refs/tags/v0.3.2.tar.gz
```

Build bằng CMake với toolchain ARM.

Output copy vào rootfs:

```text
/usr/bin/fw_printenv
/usr/bin/fw_setenv
/usr/lib/libubootenv.so*
```

Hai tool này rất quan trọng cho OTA A/B:

```bash
fw_setenv boot_slot B
fw_setenv rollback_slot A
fw_setenv upgrade_available 1
fw_setenv bootcount 0
```

---

## 20. Cấu hình fw_env.config

Script tạo:

```text
/etc/fw_env.config
```

Nội dung:

```text
/dev/mmcblk1 0xC0000 0x2000 0x200
```

Ý nghĩa:

| Field | Ý nghĩa |
|---|---|
| `/dev/mmcblk1` | eMMC user area |
| `0xC0000` | offset U-Boot env |
| `0x2000` | size env |
| `0x200` | sector size 512 bytes |

Đây là vị trí Linux dùng để đọc/ghi U-Boot env.

---

## 21. u-boot-initial-env

Script tạo:

```text
/etc/u-boot-initial-env
```

Nội dung:

```text
boot_slot=A
rollback_slot=A
upgrade_available=0
bootcount=0
bootlimit=3
```

Đây là default env tham khảo cho libubootenv. Các biến này phục vụ OTA A/B:

| Biến | Ý nghĩa |
|---|---|
| `boot_slot` | Slot sẽ boot tiếp theo |
| `rollback_slot` | Slot fallback nếu boot fail |
| `upgrade_available` | Đang có bản upgrade chưa confirm |
| `bootcount` | Số lần boot thử |
| `bootlimit` | Giới hạn boot thử |

---

## 22. ota-confirm-boot.sh

Script tạo:

```text
/usr/bin/ota-confirm-boot.sh
```

Nội dung chính:

```sh
SLOT=$(sed -n 's/.*ota.slot=\([^ ]*\).*/\1/p' /proc/cmdline)

if [ -z "$SLOT" ]; then
    echo "ota-confirm: no ota.slot"
    exit 0
fi

fw_setenv boot_slot "$SLOT"
fw_setenv rollback_slot "$SLOT"
fw_setenv upgrade_available 0
fw_setenv bootcount 0
```

Ý nghĩa:

Khi Linux boot thành công, script đọc `ota.slot=A/B` từ `/proc/cmdline`.

Nếu boot OK ở slot B:

```text
ota.slot=B
```

nó confirm:

```bash
fw_setenv boot_slot B
fw_setenv rollback_slot B
fw_setenv upgrade_available 0
fw_setenv bootcount 0
```

Như vậy lần sau U-Boot coi slot B là slot tốt.

---

## 23. rc.local

Script tạo `/etc/rc.local`.

Có 3 phần chính.

### 23.1. Chạy ota-confirm

```sh
/usr/bin/ota-confirm-boot.sh &
```

Chạy background để confirm slot boot OK.

### 23.2. WiFi reconnect loop

Loop này kiểm tra `wlan0` đã có IP chưa.

Nếu chưa có IP:

```sh
killall wpa_supplicant
ifconfig wlan0 up
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
udhcpc -i wlan0 -n -q
```

Sau đó sleep 10 giây rồi kiểm tra lại.

### 23.3. App MQTT watchdog loop

Loop này đợi WiFi sẵn sàng rồi chạy:

```sh
/usr/bin/mqtt_led_app >> /var/log/mqtt_led_app.log 2>&1
```

Nếu app exit, loop sẽ restart sau 5 giây.

Đây là lý do khi kill app, nó tự chạy lại.

Muốn tắt tạm app:

```sh
chmod -x /usr/bin/mqtt_led_app
killall -9 mqtt_led_app
```

---

## 24. Repack rootfs

Script repack:

```bash
cd "${ROOTFS}"
rm -f rootfs-console.tar.bz2
fakeroot tar cvjf rootfs-console.tar.bz2 *
```

Output:

```text
rootfs-console.tar.bz2
```

`fakeroot` giúp giữ ownership/permission kiểu root trong tarball mà không cần chạy toàn bộ tar bằng root thật.

---

## 25. Chuẩn bị thư mục flash

Script copy:

```bash
cp "${ROOTFS}/rootfs-console.tar.bz2" "${FLASH_DIR}/"
cp "${KERNEL_SRC}/arch/arm/boot/zImage" "${FLASH_DIR}/"
cp "${KERNEL_SRC}/arch/arm/boot/dts/okmx6ull-s-emmc.dtb" "${FLASH_DIR}/"
```

Sau bước này, `${FLASH_DIR}` có ít nhất:

```text
rootfs-console.tar.bz2
zImage
okmx6ull-s-emmc.dtb
```

---

## 26. boot.cmd và boot.scr

Script tạo `boot.cmd`, sau đó compile thành `boot.scr`:

```bash
mkimage -A arm -T script -C none -n "A/B OTA boot script" -d boot.cmd boot.scr
```

`boot.cmd` là script dạng text.

`boot.scr` là U-Boot script image có header hợp lệ để U-Boot chạy bằng lệnh `source`.

### 26.1. Vì sao cần boot.scr?

Log U-Boot Forlinx đã cho thấy bootloader ưu tiên tìm:

```text
reading boot.scr
```

Nếu có `boot.scr`, U-Boot sẽ chạy logic trong đó trước khi fallback sang `zImage`.

Vì vậy `boot.scr` là nơi hợp lý để đặt logic A/B mà không cần nhồi bootcmd dài vào U-Boot env.

### 26.2. Logic chọn slot

Nếu chưa có `boot_slot`, mặc định A:

```sh
if test -z "${boot_slot}"; then
    setenv boot_slot A
fi
```

Nếu `boot_slot=B`:

```sh
setenv image zImage_B
setenv fdt_file okmx6ull-s-emmc_B.dtb
setenv mmcroot /dev/mmcblk1p3 rootwait rw
```

Nếu không, dùng slot A:

```sh
setenv image zImage_A
setenv fdt_file okmx6ull-s-emmc_A.dtb
setenv mmcroot /dev/mmcblk1p2 rootwait rw
```

### 26.3. Truyền bootargs

```sh
setenv bootargs console=${console},${baudrate} calibrate=${calibrate} cma=64M root=${mmcroot} ota.slot=${boot_slot}
```

Dòng này truyền vào Linux:

```text
root=/dev/mmcblk1p2 rootwait rw ota.slot=A
```

hoặc:

```text
root=/dev/mmcblk1p3 rootwait rw ota.slot=B
```

Check trên board:

```sh
cat /proc/cmdline
```

### 26.4. Load kernel và dtb

```sh
fatload mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}
fatload mmc ${mmcdev}:${mmcpart} ${fdt_addr} ${fdt_file}
bootz ${loadaddr} - ${fdt_addr}
```

U-Boot đọc file từ FAT boot partition.

### 26.5. Rollback khi boot fail

Nếu `bootz` fail, script chạy:

```sh
setenv boot_slot ${rollback_slot}
setenv upgrade_available 0
setenv bootcount 0
saveenv
```

Sau đó chọn lại image/rootfs theo `rollback_slot` và boot lại.

Ví dụ:

```text
boot_slot=B
rollback_slot=A
zImage_B hỏng
→ bootz fail
→ set boot_slot=A
→ boot zImage_A
```

---

## 27. Tạo rootfs_wifi.wic

Script tạo file `create_rootfs_wifi_wic.sh`.

File này tạo full disk image `.wic` dung lượng 2GB:

```bash
dd if=/dev/zero of="$IMG" bs=1M count=2048
```

Layout:

| Partition | Range | Size | Mount |
|---|---:|---:|---|
| p1 | 8MiB → 72MiB | 64MiB | BOOT FAT |
| p2 | 72MiB → 840MiB | 768MiB | rootfs_A |
| p3 | 840MiB → 1608MiB | 768MiB | rootfs_B |
| p4 | 1608MiB → 100% | ~440MiB | data |

---

## 28. Format partition

```bash
sudo mkfs.vfat -F 32 -n BOOT "${LOOP_DEV}p1"
sudo mkfs.ext4 -F -L rootfs_A "${LOOP_DEV}p2"
sudo mkfs.ext4 -F -L rootfs_B "${LOOP_DEV}p3"
sudo mkfs.ext4 -F -L data "${LOOP_DEV}p4"
```

Ý nghĩa:

| Partition | Format |
|---|---|
| p1 | FAT32 |
| p2 | ext4 |
| p3 | ext4 |
| p4 | ext4 |

---

## 29. Copy boot files A/B

Script copy:

```bash
sudo cp "$KERNEL" "$BOOT_MNT/zImage_A"
sudo cp "$KERNEL" "$BOOT_MNT/zImage_B"

sudo cp "$DTB" "$BOOT_MNT/okmx6ull-s-emmc_A.dtb"
sudo cp "$DTB" "$BOOT_MNT/okmx6ull-s-emmc_B.dtb"

sudo cp "$KERNEL" "$BOOT_MNT/zImage"
sudo cp "$DTB" "$BOOT_MNT/okmx6ull-s-emmc.dtb"

sudo cp boot.scr "$BOOT_MNT/boot.scr"
```

Kết quả FAT boot partition có:

```text
boot.scr
zImage_A
zImage_B
zImage
okmx6ull-s-emmc_A.dtb
okmx6ull-s-emmc_B.dtb
okmx6ull-s-emmc.dtb
```

`zImage` và `okmx6ull-s-emmc.dtb` là fallback compatibility cho bootcmd cũ.

---

## 30. Extract rootfs A/B

```bash
sudo tar --numeric-owner -xpf "$ROOTFS" -C "$ROOT_A_MNT"
sudo tar --numeric-owner -xpf "$ROOTFS" -C "$ROOT_B_MNT"
```

Cả slot A và slot B ban đầu đều chứa cùng một rootfs.

Sau OTA, app có thể update rootfs inactive slot.

---

## 31. Data partition

Script tạo:

```bash
sudo mkdir -p "$DATA_MNT/ota"
sudo mkdir -p "$DATA_MNT/log"
sudo mkdir -p "$DATA_MNT/app"
```

Partition data có thể dùng để chứa:

| Thư mục | Gợi ý dùng |
|---|---|
| `/ota` | file OTA cache |
| `/log` | log persistent |
| `/app` | app/user data |

---

## 32. Luồng OTA kernel

Khi app nhận MQTT:

```json
{
  "cmd": "ota",
  "type": "kernel",
  "version": "x.y.z",
  "url": "http://host:8888/zImage"
}
```

App làm:

```text
current=A → inactive=B
download zImage
copy vào /mnt/boot/zImage_B
fw_setenv rollback_slot A
fw_setenv boot_slot B
fw_setenv upgrade_available 1
reboot
```

Sau reboot:

```text
boot.scr thấy boot_slot=B
→ load zImage_B
→ root=/dev/mmcblk1p3
→ ota.slot=B
```

Nếu boot thành công, Linux chạy `ota-confirm-boot.sh` và confirm B.

Nếu kernel hỏng, `bootz` fail, `boot.scr` rollback về A.

---

## 33. Luồng OTA rootfs

Khi app nhận MQTT:

```json
{
  "cmd": "ota",
  "type": "rootfs",
  "version": "x.y.z",
  "url": "http://host:8888/rootfs-console.tar.bz2"
}
```

App nên làm:

```text
current=A → inactive=B
download rootfs tar.bz2
mount /dev/mmcblk1p3 /mnt/rootfs_update
xóa nội dung cũ
tar -xjf rootfs mới vào đó
fw_setenv rollback_slot A
fw_setenv boot_slot B
fw_setenv upgrade_available 1
reboot
```

Vì rootfs hiện tại không có `mkfs.ext4/mke2fs`, app không nên format partition trên board. Thay vào đó dùng partition đã format sẵn trong `.wic`, mount rồi xóa nội dung.

BusyBox tar không hỗ trợ `--numeric-owner`, nên trên board nên dùng:

```sh
tar -xjf rootfs-console.tar.bz2 -C /mnt/rootfs_update
```

không dùng:

```sh
tar --numeric-owner -xjf ...
```

---

## 34. Luồng OTA app

Khi app nhận MQTT:

```json
{
  "cmd": "ota",
  "type": "app",
  "version": "x.y.z",
  "url": "http://host:8888/mqtt_led_app"
}
```

App tải binary mới:

```text
/tmp/mqtt_led_app_new
```

sau đó:

```text
chmod +x
mv vào /usr/bin/mqtt_led_app
killall mqtt_led_app
```

Do `rc.local` có watchdog loop, app sẽ tự restart.

---

## 35. Các lỗi từng gặp và nguyên nhân

### 35.1. Không có `ota.slot`

Nếu:

```sh
cat /proc/cmdline
```

không có:

```text
ota.slot=A
```

nghĩa là `boot.scr` chưa chạy hoặc bootcmd cũ đang boot thẳng `zImage`.

### 35.2. `fw_printenv` không đọc được env

Cần đúng `/etc/fw_env.config`.

Hiện đang dùng:

```text
/dev/mmcblk1 0xC0000 0x2000 0x200
```

Nếu offset sai thì `fw_printenv/fw_setenv` lỗi.

### 35.3. `wget: unrecognized option --progress=bar:force`

Board dùng BusyBox wget, không hỗ trợ option GNU wget đó.

Dùng:

```sh
wget -O file URL
```

hoặc:

```sh
wget --no-check-certificate -O file URL
```

### 35.4. `mkfs.ext4: command not found`

Rootfs thiếu `e2fsprogs`.

Cách hiện tại: không format trên board, chỉ mount/xóa/extract.

Cách production hơn: thêm `e2fsprogs-mke2fs` vào rootfs.

### 35.5. `tar: unrecognized option --numeric-owner`

BusyBox tar không hỗ trợ `--numeric-owner`.

Dùng:

```sh
tar -xjf file.tar.bz2 -C /mnt/rootfs_update
```

---

## 36. File output cuối cùng

Sau khi script chạy xong, `${FLASH_DIR}` nên có:

```text
rootfs-console.tar.bz2
zImage
okmx6ull-s-emmc.dtb
boot.cmd
boot.scr
create_rootfs_wifi_wic.sh
rootfs_wifi.wic
```

Các file dùng để flash:

| File | Dùng làm gì |
|---|---|
| `rootfs_wifi.wic` | Full eMMC image |
| `zImage` | Kernel |
| `okmx6ull-s-emmc.dtb` | Device tree |
| `boot.scr` | Logic boot A/B |
| `rootfs-console.tar.bz2` | Rootfs OTA package |

---

## 37. Cách kiểm tra sau khi flash

Trên U-Boot:

```sh
fatls mmc 1:1
```

Phải thấy:

```text
boot.scr
zImage_A
zImage_B
okmx6ull-s-emmc_A.dtb
okmx6ull-s-emmc_B.dtb
```

Trên Linux:

```sh
cat /proc/cmdline
```

Expected slot A:

```text
root=/dev/mmcblk1p2 rootwait rw ota.slot=A
```

Expected slot B:

```text
root=/dev/mmcblk1p3 rootwait rw ota.slot=B
```

Check app log:

```sh
tail -f /var/log/mqtt_led_app.log
```

Check env:

```sh
fw_printenv boot_slot
fw_printenv rollback_slot
fw_printenv upgrade_available
fw_printenv bootcount
```

---

## 38. Kết luận

Script này đã tạo được nền OTA A/B gồm:

```text
BOOT partition chung
rootfs_A
rootfs_B
data partition
boot.scr chọn slot
Linux confirm boot
MQTT app điều khiển OTA
fw_setenv cập nhật trạng thái boot
```

Kiến trúc hiện tại phù hợp demo/prototype và có thể đưa lên production nhỏ nếu bổ sung thêm:

1. Hash/signature kiểm tra file OTA.
2. Version compare.
3. Watchdog bootcount thật.
4. e2fsprogs hoặc update rootfs bằng image ext4.
5. Log OTA rõ ràng hơn.
6. Chặn update nhầm type, ví dụ rootfs gửi vào kernel.
7. Tách config WiFi/MQTT ra file riêng thay vì hardcode.
