# Chapter 2 — Core Resources Evaluation

In Linux, the PROC virtual file system is provided to query parameters of various core resources, along with common tools to evaluate resource performance. The following sections cover CPU, Memory, Flash (eMMC/NAND), RTC, Watchdog, and Power Manager.

---

## 2.1. CPU

The **i.MX 6UltraLite** is a high performance, ultra-efficient processor featuring NXP's advanced implementation of the single **ARM Cortex®-A7** core, operating at speeds up to **528 MHz**. It includes an integrated power management module and supports various memory interfaces: LPDDR2, DDR3, DDR3L, Raw/Managed NAND Flash, NOR Flash, eMMC, Quad SPI, and peripherals such as WLAN, Bluetooth™, GPS, displays, and camera sensors.

### 1) View CPU Information

Read CPU provider and parameter information via `/proc/cpuinfo`:

```bash
root@myd-y6ull14x14:~# cat /proc/cpuinfo
processor : 0
model name : ARMv7 Processor rev 5 (v7l)
BogoMIPS : 24.00
Features : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae
CPU implementer : 0x41
CPU architecture: 7
CPU variant : 0x0
CPU part : 0xc07
CPU revision : 5
Hardware : Freescale i.MX6 Ultralite (Device Tree)
Revision : 0000
Serial : 0323b1d75986e1d8
```

| Field | Description |
|---|---|
| `processor` | Number of logical processing cores (physical or hyperthreaded virtual cores) |
| `model name` | CPU name and model |
| `BogoMIPS` | Rough measure of millions of instructions per second at kernel startup |

### 2) View CPU Utilization

```bash
root@myd-y6ull14x14:~# top
```

```
top - 11:02:51 up 2:17, 1 user, load average: 0.70, 0.65, 0.64
Tasks: 71 total, 2 running, 69 sleeping, 0 stopped, 0 zombie
%Cpu(s): 1.0 us, 0.3 sy, 0.0 ni, 98.6 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
MiB Mem: 490.0 total, 318.7 free, 106.1 used, 65.1 buff/cache
MiB Swap: 0.0 total, 0.0 free, 0.0 used. 364.5 avail Mem
```

| Field | Description |
|---|---|
| `%us` | CPU utilization of user space programs (not scheduled by NICE) |
| `%sy` | CPU utilization of system/kernel space |
| `%ni` | CPU usage of user space programs scheduled via NICE |
| `%id` | Idle CPU |

### 3) Get CPU Temperature

The CPU has a built-in temperature sensor accessible via the hardware monitoring module:

```bash
root@myd-y6ull14x14:~# cat /sys/class/thermal/thermal_zone0/temp
52730
```

> The value is in **1/1000 °C** — divide by 1000 to get the actual temperature (e.g., 52730 → **52.73°C**).

### 4) CPU Stress Test

Use the `bc` command to calculate PI in the background and monitor CPU utilization:

```bash
root@myd-y6ull14x14:~# echo "scale=5000; 4*a(1)" | bc -l -q &
[1] 507
```

This calculates PI to 5000 decimal places in the background. Monitor CPU usage with `top`:

```bash
root@myd-y6ull14x14:~# top
```

```
%Cpu(s): 25.1 us, 0.0 sy, 0.0 ni, 74.9 id ...
PID  USER  PR  NI  VIRT  RES   SHR  S  %CPU  %MEM  TIME+   COMMAND
784  root  20   0  2728  1644  1392  R  99.7   0.1  0:42.56  bc
```

After ~3 minutes the calculation completes with no exceptions, confirming the CPU stress test passed. Increase the `scale` value for higher pressure testing.

---

## 2.2. Memory

The i.MX6UL supports external SDRAM up to **8 Gigabit (1GB)**, with 16 or 32-bit **LPDDR2 or DDR3** at **400 MHz**.

### 1) Check Memory Information

```bash
root@myd-y6ull14x14:~# cat /proc/meminfo
MemTotal:    501788 kB
MemFree:     326380 kB
MemAvailable: 373268 kB
Buffers:       4208 kB
Cached:       56212 kB
SwapCached:       0 kB
Active:       35820 kB
Inactive:     47996 kB
...
```

| Field | Description |
|---|---|
| `MemTotal` | All available RAM (physical memory minus reserved bits and kernel usage) |
| `MemFree` | LowFree + HighFree |
| `Buffers` | Cache size used for block devices |
| `Cached` | Buffer size for files |
| `SwapCached` | Memory that has been swapped out |
| `Active` | Frequently/recently used memory |
| `Inactive` | Memory not recently used |

### 2) Get Memory Usage

```bash
root@myd-y6ull14x14:~# free -m
              total   used   free  shared  buff/cache  avail
Mem:            490    106    318       9          65    364
Swap:             0      0      0
```

| Field | Description |
|---|---|
| `total` | Total memory |
| `used` | Amount of memory in use |
| `free` | Amount of memory available |

### 3) Memory Stress Test

Use `memtester` to test memory stability. Example: test 300 MB once:

```bash
root@myd-y6ull14x14:~# memtester 300M 1
memtester version 4.3.0 (64-bit)
...
Loop 1/1:
  Stuck Address       : ok
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok
  Block Sequential    : ok
  Checkerboard        : ok
  Bit Spread          : ok
  Bit Flip            : ok
  Walking Ones        : ok
  Walking Zeroes      : ok
Done.
```

---

## 2.3. Flash

### eMMC

eMMC is a communication and mass data storage device combining an MMC interface, NAND Flash, and a controller. The i.MX6UL supports an **8-bit SDMMC interface (eMMC v4.51)** with maximum support of **128 GB**.

#### View eMMC Capacity

```bash
root@myd-y6ull14x14:~# fdisk -l
Disk /dev/mmcblk1: 3672 MB, 3850371072 bytes, 7520256 sectors
Device         Boot  StartLBA   EndLBA   Sectors  Size  Type
/dev/mmcblk1p1        20480    122879   102400   50.0M  Win95 FAT32 (LBA)
/dev/mmcblk1p2       122880   7520255  7397376  3612M  Linux
```

| Partition | Usage |
|---|---|
| `/dev/mmcblk1p1` | Bootloader |
| `/dev/mmcblk1p2` | Root file system |

#### View eMMC Partition Information

```bash
root@myd-y6ull14x14:~# df -h
Filesystem       Size  Used  Avail  Use%  Mounted on
/dev/root        487M  328M   131M   72%  /
devtmpfs         181M  4.0K   181M    1%  /dev
tmpfs            246M     0   246M    0%  /dev/shm
/dev/mmcblk1p1    25M  9.0M    16M   37%  /run/media/mmcblk1p1
/dev/mmcblk1p2   149M   86M    53M   63%  /run/media/mmcblk1p2
```

| Filesystem | Description |
|---|---|
| `/dev/root` | Root file system, mounted to root directory |
| `tmpfs` | Memory virtual file system |
| `devtmpfs` | Used to create `/dev` for the system |

### NAND Flash

#### Partition Definition

NAND partition structure is defined in U-Boot and passed to the kernel at boot:

```c
#define MFG_NAND_PARTITION \
  "mtdparts=gpmi-nand:5m(boot),1m(env),10m(kernel),1m(dtb),-(rootfs)"
```

#### View Partitions After Boot

```bash
root@myd-y6ull14x14:~# cat /proc/mtd
dev:      size    erasesize  name
mtd0: 00500000  00020000  "boot"
mtd1: 00100000  00020000  "env"
mtd2: 00a00000  00020000  "kernel"
mtd3: 00100000  00020000  "dtb"
mtd4: 0ef00000  00020000  "rootfs"
```

#### View Partition Parameters

```bash
root@myd-y6ull14x14:~# cat /proc/cmdline
console=ttymxc0,115200 ubi.mtd=4 root=ubi0:rootfs rootfstype=ubifs
mtdparts=gpmi-nand:5m(boot),1m(env),10m(kernel),1m(dtb),-(rootfs)
```

| Parameter | Description |
|---|---|
| `ubi.mtd` | Partition of the file system |
| `rootfstype` | Format of the file system |
| `root` | Root file system target |
| `console` | Debug serial port parameters |

---

## 2.4. RTC

The **i.MX6UL** chip contains an internal RTC clock that retains time when powered off.

> **Note:** If the product requires the RTC to hold time for more than one month during power-off, an external RTC chip is recommended over the internal one.

Testing is done with the standard Linux `hwclock` and `date` commands.

### View RTC Devices

```bash
root@myd-y6ull14x14:~# ls -l /dev/rtc*
lrwxrwxrwx 1 root root 4 Sep 5 03:14 /dev/rtc -> rtc0
crw------- 1 root root 251, 0 Sep 5 03:14 /dev/rtc0
crw------- 1 root root 251, 1 Sep 5 03:14 /dev/rtc1
```

> `/dev/rtc0` is the default RTC device driver node for applications.

### Set System Time

```bash
root@myd-y6ull14x14:~# date 090809072020.30
Tue Sep 8 09:07:30 UTC 2020
```

### Write System Time to RTC

```bash
root@myd-y6ull14x14:~# hwclock -w
```

### Read Time from RTC

```bash
root@myd-y6ull14x14:~# hwclock -r
2020-09-08 09:08:02.588845+00:00
```

### Verify RTC Keeps Time During Power-Off

Power off for ~2 minutes, then reboot and check:

```bash
root@myd-y6ull14x14:~# hwclock -r
2020-09-08 09:10:50.206047+00:00
```

The RTC time increased by ~2 minutes — RTC is working normally. For precision testing, extend the power-off period (e.g., 24 hours) and compare with standard time.

### Sync System Time from RTC

```bash
root@myd-y6ull14x14:~# hwclock -s
root@myd-y6ull14x14:~# date
Tue Sep 8 09:11:07 UTC 2020
```

> Add `hwclock -s` to the Linux startup script to automatically sync system time with RTC on every boot.

---

## 2.5. Watchdog

The MYD-Y6ULX includes an internal watchdog timer. When the system fails to "feed the dog" within the timeout period, the system automatically resets.

### 1) Stop the Watchdog

```bash
root@myd-y6ull14x14:~# echo V > /dev/watchdog0
```

> **Note:** Due to the `nowayout` attribute, the system may not be able to fully disable the watchdog.

### 2) Application-Based Watchdog Testing

#### Set Timeout via IOCTL

```c
ioctl(fd, WDIOC_SETTIMEOUT, &timeout);
```

`fd` is the file handle of the watchdog device.

#### Demo Application

```bash
root@myir:~# watchdog_test
Usage: wdt_driver_test <timeout> <sleep> <test>
  timeout: seconds before watchdog triggers reset
  sleep:   seconds between feeding the watchdog
  test:    0 - feed with ioctl()  |  1 - feed with write()
```

Run with 4s timeout, feeding every 1s:

```bash
root@myd-y6ull14x14:~# watchdog_test 4 1 0
Starting wdt_driver (timeout: 4, sleep: 1, test: ioctl)
Trying to set timeout value=4 seconds
The actual timeout was set to 4 seconds
Now reading back -- The timeout is 4 seconds
```

> If the sleep value is set greater than the timeout (e.g., `watchdog_test 4 5 0`), the board will reset after the 4s feeding window expires.

---

## 2.6. Power Manager

The Linux kernel provides three suspend modes that can be triggered by writing to `/sys/power/state`:

| Mode | Trigger Value | Description |
|---|---|---|
| Freeze | `freeze` | Freezes user-space processes |
| Standby | `standby` | Light sleep mode |
| Suspend to RAM | `mem` | Deep sleep, lowest power |

### 1) View Supported Power Modes

```bash
root@myd-y6ull14x14:~# cat /sys/power/state
freeze standby mem
```

### 2) Enter `mem` (Deep Sleep) Mode

```bash
root@myd-y6ull14x14:~# echo "mem" > /sys/power/state
[ 278.716505] PM: suspend entry (deep)
[ 278.741713] Freezing user space processes ... done.
[ 278.762886] printk: Suspending console(s)
```

### 3) Wake Up via KEY Button

While in `mem` mode, the debug port stops accepting input and the heartbeat LED stops flashing. Press button **K3** on the development board to wake the system:

```
[ 279.526926] PM: resume devices took 0.650 seconds
[ 279.563503] Restarting tasks ... done.
[ 279.630415] PM: suspend exit
root@myd-y6ull14x14:~#
```

After waking, the debug port resumes input and the heartbeat LED starts flashing again.