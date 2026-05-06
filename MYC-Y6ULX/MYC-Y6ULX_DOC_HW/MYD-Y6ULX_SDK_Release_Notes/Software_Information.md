# MYD-Y6ULX Software Release Notes

> Document: MYIR-MYD-Y6ULX-SW-RN-EN-L5.10.9

---

## 2. Software Overview

The MYD-Y6ULX Linux system is built with Yocto projects. Two different types of image files are offered for different usage scenarios:

### Table 2-1. MYD-Y6ULX Images Description

| Image File Name | Content Description |
|---|---|
| `myir-image-core` | Image **without** GUI interface, built by Yocto project. Contains complete hardware drivers, common system tools, debugging tools, etc. Supports Shell, C/C++, Python for application development. |
| `myir-image-full` | Image **with** GUI interface, built by Yocto project. Contains complete hardware drivers, common system tools, debugging tools, QT runtime library and HMI interface based on QT development. Supports Shell, C/C++, QML, Python for application development. |

**Notes:**
1. Since the QtMultimedia and Gstreamer components occupy a large amount of space, the `myir-image-full` images of **256 MB NAND** configured platforms will not include the multimedia function by default.
2. For content not included in the image file, users can add or contact MYIR for support.

---

## 2.1. Functional Characteristics

### Table 2-2. MYD-Y6ULX Software Features List

| Class | Function | Description | FULL | CORE |
|---|---|---|:---:|:---:|
| **Bootloader** | U-Boot | NAND support read/write, erase | ✅ | ✅ |
| | | NAND supports fat, ubi file system mount access | ✅ | ✅ |
| | | EMMC/TF card supports scanning, reading and writing | ✅ | ✅ |
| | | EMMC/TF card supports fat file system access | ✅ | ✅ |
| | | Complete upgrade of image through TF card | ✅ | ✅ |
| | | Ethernet supports networking, PING, TFTP protocols | ✅ | ✅ |
| | | Ethernet supports DHCPC Protocol | ✅ | ✅ |
| | | Ethernet supports NFS startup | ✅ | ✅ |
| | | Complete image upgrade via Ethernet | ✅ | ✅ |
| | | USB Mass storage | ✅ | ✅ |
| | | USB RNDIS protocol | ✅ | ✅ |
| | | USB fastboot | ✅ | ✅ |
| | | USB DFU protocol | ✅ | ✅ |
| | | Complete upgrade of image through USB port | ✅ | ✅ |
| | | Device Tree FIT | ✅ | ✅ |
| | | Memory read-write test, MDIO read-write, I2C read-write, reset | ✅ | ✅ |
| **Kernel Network** | TCP/IP network protocol stack | | ✅ | ✅ |
| | Ethernet protocol | | ✅ | ✅ |
| | Net Bridge, IP Route, Netfilter | | ✅ | ✅ |
| | PPP protocol and USB serial | | ✅ | ✅ |
| | CAN bus subsystem | | ✅ | ✅ |
| | IrDA (infrared) subsystem | | ✅ | ✅ |
| | Bluetooth subsystem | | ✅ | ✅ |
| | Wireless protocol stack | | ✅ | ✅ |
| | RF Switch subsystem | | ✅ | ✅ |
| | IPV6 | | ✅ | ✅ |
| **File Systems** | DEVTMPFS | | ✅ | ✅ |
| | Ext2/3/4 File System | | ✅ | ✅ |
| | UBIFS File System | | ✅ | ✅ |
| | Overlay File System | | ✅ | ✅ |
| | Network File System | | ✅ | ✅ |
| | MSDOS File System | | ✅ | ✅ |
| | VFAT File System | | ✅ | ✅ |
| | Jffs2 File System | | ✅ | ✅ |
| | Squash File System | | ✅ | ✅ |
| | NTFS File System | | ✅ | ✅ |
| **Multimedia Modules** | Video input module, uvc, v4l2 | Multimedia related modules | ✅ | ❌ |
| **Sound Modules** | ALSA audio input/output | Audio-related modules | ✅ | ❌ |
| **Graphics Modules** | Backlight, display, GPU | Display related modules | ✅ | ❌ |
| **Input Subsystem** | Button, HID, touch subsystem | Platform-supported input devices | ✅ | ❌ |
| **USB Gadget** | Mass storage, rndis, serial | | ✅ | ✅ |
| **Root File System** | Kernel firmware | rtlwifi firmware, bcmwifi firmware | ✅ | ✅ |
| | Initial subsystem | Systemd/systemV/busybox (select systemd) | ✅ | ✅ |
| | | Udev (include udev rules) | ✅ | ✅ |
| | | Login | ✅ | ✅ |
| **System Tools** | Bash shell environment | | ✅ | ✅ |
| | coreutils | chgrp, chmod, chown, kill, cp, dd... | ✅ | ✅ |
| | util-linux | sfdisk, fdisk, fsck... | ✅ | ✅ |
| | tar with long options | | ✅ | ✅ |
| | ubi-utils | ubiattach, ubidetach, mkfs.ubifs... | ✅ | ✅ |
| | top | | ✅ | ✅ |
| | u-boot-tools | fw_printenv, fw_setenv | ✅ | ✅ |
| | e2fsck | | ✅ | ✅ |
| | resize2fs | | ✅ | ✅ |
| | genext2fs | | ✅ | ✅ |
| | gzip | | ✅ | ✅ |
| **System Settings** | Localized data | C en_US | ✅ | ✅ |
| | Time zone information | Asia/Shanghai | ✅ | ✅ |
| | User and password | Account: root, password: empty | ✅ | ✅ |
| **Test Tools** | memtester | | ✅ | ✅ |
| | i2c-tools | | ✅ | ✅ |
| | mmc-utils | | ✅ | ✅ |
| | mtd-utils | | ✅ | ✅ |
| | can-utils | | ✅ | ✅ |
| | microcom | | ✅ | ✅ |
| | minicom | | ✅ | ✅ |
| | hwclock | | ✅ | ✅ |
| | spidev_test | | ✅ | ✅ |
| | gdbserver | | ✅ | ✅ |
| | evtest | | ✅ | ✅ |
| | tslib, ts_test, ts_calibrate | | ✅ | ❌ |
| | hexdump | | ✅ | ✅ |
| **Development Language** | python3.8 | | ✅ | ✅ |
| | C/C++ | | ✅ | ✅ |
| | perl | | ✅ | ✅ |
| **Database** | sqlite3 | | ✅ | ✅ |
| **Network Applications** | scp, ethtool, netstat, iptables | | ✅ | ✅ |
| | iperf3, iproute2, dns, udhcpc | | ✅ | ✅ |
| | udhcpd, tftpd, tftp, lftp, ftp | | ✅ | ✅ |
| | ntpd, pppd, ifconfig | | ✅ | ✅ |
| | openssh server (sshd) | | ✅ | ✅ |
| | openssh client (ssh) | | ✅ | ✅ |
| | wpa-supplicant, wpa_cli | | ✅ | ✅ |
| | tcpdump, bluez-utils | | ✅ | ✅ |
| | bridge-utils, telnet, route | | ✅ | ✅ |
| | avahi, samba, openssl-devel | | ✅ | ✅ |
| **Word Processing** | ncurses, readline, grep | | ✅ | ✅ |
| | sed, awk, vim (vi) | | ✅ | ✅ |
| **Graphics System** | qt5.15.0 | qtbase, qtwidget, qtquick2.0, qtmultimedia, qtvirtualkeyboard (Chinese & English) | ✅ | ❌ |
| | modetest | | ✅ | ❌ |
| | fbset | | ✅ | ❌ |
| | psplash | | ✅ | ❌ |
| | wayland | | ✅ | ❌ |
| | weston | | ✅ | ❌ |
| **Multimedia** | gstreamer | | ✅ | ❌ |
| | v4l-utils | | ✅ | ✅ |
| | alsa-utils | | ✅ | ✅ |
| | ffmpeg | | ✅ | ❌ |
| **Other** | bc, pv, dbus | | ✅ | ✅ |
| | gobject introspection | | ✅ | ✅ |
| **SDK** | Toolchain: arm-linux-gnueabi | | ✅ | ✅ |
| | C function library: glibc | | ✅ | ✅ |
| | C++ function library: libstdc++ | | ✅ | ✅ |
| | libasound, libssl-dev, libxml2 | | ✅ | ✅ |

> **Note:** The table lists some of the software features. For a complete list, please refer to the manifest file in the CD image.

---

## 2.2. Software List

The MYD-Y6ULX bootloader, kernel, file system, and application source code are completely open. Source code is available via the CD image or the following code hosting platforms:

### U-Boot
- **Version:** V2020.04
- **URL:** https://github.com/MYiR-Dev/myir-imx-uboot.git
- **Branch:** `develop_2020.04`

### Linux Kernel
- **Version:** V5.10.9
- **URL:** https://github.com/MYiR-Dev/myir-imx-linux.git
- **Branch:** `develop_lf-5.10.y`

### Yocto Manifest
- **Version:** V5.10-gatesgarth
- **URL:** https://github.com/MYiR-Dev/myir-imx-manifest.git
- **Branch:** `i.MX6UL-5.10-gatesgarth`

### Yocto Meta
- **Version:** V5.10-gatesgarth
- **URL:** https://github.com/MYiR-Dev/meta-myir-imx.git
- **Branch:** `i.MX6UL-5.10-gatesgarth`

### MEasy HMI
- **Version:** V2.0
- **URL:** https://github.com/MYiR-Dev/mxapp.git
- **Branch:** `hmi2.0-imx6ulx-gw-nogpu`

### Examples
- **Version:** V2.0
- **URL:** https://github.com/MYiR-Dev/myir-linux-examples.git
- **Branch:** `myd-y6ulx`

---

### Table 2-3. MYD-Y6ULX Kernel Driver List

| Module | Description | Source Path |
|---|---|---|
| MMC | eMMC driver | `drivers/mmc` |
| NAND | MTD driver | `drivers/mtd` |
| SPI | SPI driver | `drivers/spi/spi-imx.c` |
| I2C | I2C controller driver | `drivers/i2c/` |
| USB Host | USB driver | `drivers/usb/host/ohci-platform.c` / `ehci-platform.c` |
| Ethernet | Network drivers | `drivers/net/ethernet/stmicro/stmmac/fec_main.c` |
| RS232/RS485/UART | Serial driver | `drivers/tty/serial/imx.c` |
| CAN bus | CAN bus driver | `drivers/net/can/flexcan.c` |
| GPIO key | Key driver | `drivers/input/keyboard/gpio_keys.c` |
| WiFi & BT | Brcm driver | `drivers/net/wireless/broadcom/brcm80211/brcmfmac/` |
| RTC | RTC driver | `drivers/rtc/rtc-snvs.c` |
| GPIO LED | LED driver | `drivers/leds/leds-gpio.c` |
| LCD | LTDC driver | `drivers/video/fbdev/mxsfb.c` |
| Touch | Touchscreen driver | `drivers/input/touchscreen/edt-ft5x06.c` |

---

## 2.3. Document Information

The SDK contains different categories of documents for different development stages:

- **Quick Start Guide** — How to quickly connect hardware, start the development board, and access information for evaluation and development.
- **Evaluation Guide** — Detailed hardware and software characteristics with demonstrations for project evaluation.
- **Development Guide** — Full process for porting operating systems and applications to custom hardware platforms using our CPU module.
- **Application Notes** — Detailed guides for developing specific functions or modules.
- **FAQ** — Frequently asked questions summarized from each development stage.

### Table 2-4. MYD-Y6ULX SDK Document List

| Use Phase | Document Name | Status |
|---|---|---|
| Evaluation Stage | MYD-Y6ULX Linux Software Evaluation Guide | Released |
| Development Stage | MYD-Y6ULX Software Development Guide | Released |
| Application Note | — | Not released |
| Support | MYD-Y6ULX Software FAQ | Not released |
| Release Notes | MYD-Y6ULX Software Release Notes | Released |