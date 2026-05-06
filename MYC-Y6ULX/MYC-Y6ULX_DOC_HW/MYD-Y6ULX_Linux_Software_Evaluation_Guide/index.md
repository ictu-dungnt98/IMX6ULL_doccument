# MYD-Y6ULX Documentation Index

> MYIR Electronics — i.MX6UL Series Development Board

---

## 📄 SDK Release Notes

| # | Document | Description |
|---|---|---|
| 1 | [Software Release Notes — Part 1](MYD-Y6ULX-Software-Release-Notes.md) | Images overview, software features list, kernel drivers, source code URLs, document list |
| 2 | [Software Release Notes — Part 2](MYD-Y6ULX-Release-Notes-Part2.md) | Version history, remaining problems, warranty & technical support |

---

### Release Notes — Detailed Sections

| Section | Document |
|---|---|
| Chapter 3 — Version History | [3-Version-History.md](3-Version-History.md) |
| Chapter 4 — Remaining Problems | [4-Remaining-Problems.md](4-Remaining-Problems.md) |
| Appendix A — Warranty & Support | [Appendix-A-Warranty-and-Support.md](Appendix-A-Warranty-and-Support.md) |

---

## 📘 Linux Software Evaluation Guide

> Document: MYIR-MYD-Y6ULX-SW-EG-EN-L5.10.9

| Chapter | Document | Topics |
|---|---|---|
| Chapter 1 | [Introduction](EG-Chapter1-Introduction.md) | Hardware resources, software resources, documents, preparation |
| Chapter 2 | [Core Resources](EG-Chapter2-Core-Resources.md) | CPU, Memory, Flash (eMMC/NAND), RTC, Watchdog, Power Manager |
| Chapter 3 | [Peripheral Interfaces](EG-Chapter3-Peripheral-Interfaces.md) | GPIO, LED, RS232, RS485, CAN, Key, USB, Backlight, Touch Panel, Display |
| Chapter 4 | [Network Applications](EG-Chapter4-Network-Applications.md) | Ethernet configuration, Wi-Fi (STA mode, auto-connect) |
| Chapter 5 | [Common Network Apps](EG-Chapter5-Common-Network-Apps.md) | PING, SSH, SCP, FTP, TFTP, UDHCPC, IPTables, Ethtool, iPerf3 |
| Chapter 6 | [Graphics System / Qt](EG-Chapter6-Graphics-QT.md) | Qt platform plugins, display config, input devices, starting Qt apps |
| Chapter 7 | [Multimedia](EG-Chapter7-Multimedia.md) | Camera (uvc_stream), Audio (aplay), Video |
| Chapter 8 | [System Tools](EG-Chapter8-System-Tools.md) | Compress/decompress, filesystem tools, disk management, process management |
| Chapter 9 | [Development Support](EG-Chapter9-Development-Support.md) | Shell, C/C++, Python, SQLite, Qt localization, fonts, virtual keyboard |

---

## 🔗 Quick Reference

### Key Commands

| Task | Command |
|---|---|
| View CPU info | `cat /proc/cpuinfo` |
| View memory | `cat /proc/meminfo` |
| View eMMC partitions | `fdisk -l` |
| Check RTC | `hwclock -r` |
| View network interfaces | `ifconfig -a` |
| Scan Wi-Fi | `iw dev wlan0 scan \| grep SSID` |
| View processes | `ps aux` |
| Kill process by name | `killall <name>` |
| Check disk usage | `df -h` |
| Run Qt app | `./mxapp2 -platform linuxfb &` |

### Key File Paths

| Path | Description |
|---|---|
| `/sys/class/gpio/` | GPIO sysfs interface |
| `/sys/class/leds/` | LED sysfs interface |
| `/sys/class/backlight/` | Backlight sysfs interface |
| `/sys/class/thermal/thermal_zone0/temp` | CPU temperature |
| `/sys/power/state` | Power management modes |
| `/etc/systemd/network/` | Network configuration files |
| `/etc/wpa_supplicant/` | Wi-Fi credentials |
| `/lib/firmware/brcm/` | Wi-Fi firmware |
| `/var/lib/ftp/` | FTP server root directory |
| `/usr/lib/fonts/` | System fonts |
| `/dev/rtc0` | RTC device node |
| `/dev/watchdog0` | Watchdog device node |
| `/proc/mtd` | NAND flash partition info |

---

## 📚 External References

| Resource | URL |
|---|---|
| U-Boot source | https://github.com/MYiR-Dev/myir-imx-uboot.git |
| Linux Kernel source | https://github.com/MYiR-Dev/myir-imx-linux.git |
| Yocto Manifest | https://github.com/MYiR-Dev/myir-imx-manifest.git |
| Yocto Meta | https://github.com/MYiR-Dev/meta-myir-imx.git |
| MEasy HMI source | https://github.com/MYiR-Dev/mxapp.git |
| Linux Examples | https://github.com/MYiR-Dev/myir-linux-examples.git |
| iproute2 docs | https://wiki.linuxfoundation.org/networking/iproute2 |
| systemd.network docs | https://www.freedesktop.org/software/systemd/man/systemd.network.html |
| iptables man page | https://linux.die.net/man/8/iptables |
| ethtool man page | http://man7.org/linux/man-pages/man8/ethtool.8.html |
| iPerf3 docs | https://iperf.fr/iperf-doc.php |
| SQLite docs | https://www.sqlite.org/docs.html |
| TSLIB docs | https://github.com/libts/tslib/blob/master/README.md |
| MYIR Tech support | support@myirtech.com |