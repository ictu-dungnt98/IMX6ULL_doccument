# UUU (Universal Update Utility)

## 1. Introduction

Welcome to the **UUU (Universal Update Utility)**. This is an evolution of MFGTools (aka MFGTools v3).

UUU is Freescale/NXP I.MX Chip image deploy tools.

With the time, the need for an update utility portable to Linux and Windows increased. UUU have the same usage on both Windows and Linux. It means the same script works on both OS.

UUU is a command line tool, for example:

```
uuu (universal update utility) for nxp imx chips -- libuuu-1.0.1-gffd9837
Succues:0 Failure:3 Wait for Known USB Device Appear...
1:11 5/5 [     ] SDP: jump -f u-boot-dtb.imx - ivtinitramf....
2:1  1/5 [===> ] SDP: boot -f u-boot-imx7dsabresd_sd.imx ....
```

UUU is designed as a common library and UI. So users can easily integrate it into their tools with the uuu library. UUU also runs easily in any scripts.

> PDF of wiki content is also available at the release page.

---

## 1.1 Running Environment

- Windows 10, 64-bit — early versions (below 1.2.0) need to install the VS2017 redistribute package
- Ubuntu 16.04 or above, 64-bit

> Windows 7 users please read the WIN7-User-Guide.

---

## 1.2 Typical Usage

Set board boot pin to **serial download mode**. Generally, iMX ROM will fall back to USB serial download mode if boot fails.

**Download uboot:**
```bash
uuu bootloader
```

**Burn uboot into eMMC:**
```bash
uuu -b emmc bootloader
```

**Burn bootimage into QSPI flash:**
```bash
uuu -b qspi qspi_bootloader
```

**Burn rootfs image into eMMC:**
```bash
uuu -b emmc_all bootloader rootfs.sdcard
```

**Decompress rootfs image and burn into eMMC** *(since 1.1.87)*:
```bash
uuu -b emmc_all bootloader rootfs.sdcard.bz2/*
```

**Burn release image into eMMC:**
```bash
uuu L4.9.123_2.3.0_8mm-ga.zip
```

> **Notes:**
> - `bootloader` means a bootable image which includes the ROM required header.
> - For imx6/7, it should generally be `uboot.imx`.
> - For imx8qxp / imx8qm / imx8mm / imx8mq, it is `flash.bin`.
> - Some releases combine multiple boards into one zip package. Use `uuu release.zip/uuu.auto-<boardname>` in that case.

For more usage, refer to the **Example** section.

---

## 1.3 Typical Script

UUU's script is a plain text file.

**The first line must be:**
```
uuu_version 1.0.1
```
This version indicates the minimum version of UUU required to run the script.

Then follow with UUU commands in the format:
```
PROTOCOL: CMD
```

**Example** — boot uboot for imx6 and imx7:
```
uuu_version 1.0.1

SDP: dcd -f u-boot.imx
SDP: write -f u-boot.imx -ivt 0
SDP: jump -f u-boot.imx -ivt 0
```

For more sample scripts, see **Sample-script**.

### Fastboot Environment Variables

| Variable | Description |
|---|---|
| `fastboot_dev` | Fastboot flash device; supports `mmc` and `sata` |
| `fastboot_buffer` | Fastboot download buffer address |
| `fastboot_bytes` | Fastboot download file size |
| `emmc_dev` | eMMC device number |
| `sd_dev` | SD slot device number |

---

## 1.4 License

UUU is licensed under the **BSD license**. See LICENSE.

The BSD licensed prebuilt Windows binary version of UUU is statically linked with the LGPL libusb library, which remains LGPL.

- **bzip2** (BSD license) — from https://github.com/enthought/bzip2-1.0.6
- **zlib** (zlib license) — from https://github.com/madler/zlib.git
- **libusb** (LGPL-2.1) — from https://github.com/libusb/libusb.git

---

## 1.5 What Firmware Is Needed

| What you want | Firmware needed |
|---|---|
| Download bootloader | N/A |
| Burn image to eMMC/SD | uboot with fastboot enabled |
| Burn image to QSPI / SPI / NOR | uboot with fastboot enabled |
| Burn image into NAND flash | uboot ¹, Linux kernel / initramfs / uboot / dtb |
| Need Linux shell cmd such as fdisk | uboot ¹, Linux kernel / initramfs / uboot / dtb |
| Boot Linux kernel with rootfs already in eMMC | uboot with fastboot enabled |
| Boot Linux kernel with NFS over USB | uboot with fastboot enabled, initramfs |

> ¹ Prefer to enable fastboot. If ROM HID supports writing additional image to DDR place, you can write kernel / dtb / initramfs to DDR before jumping to uboot. Enabling fastboot gives more flexibility to change the kernel command line.

---

## 1.6 Setup Auto Parameter Complete

### 1.6.1 Windows

PowerShell supports customized auto-complete. Run the following command or put it into `Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`:

```powershell
Register-ArgumentCompleter -CommandName uuu -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    C:\Users\nxa23210\uuu\uuu\x64\Release\lib\uuu.exe -autocomplete $parameterName
}
```

### 1.6.2 Linux

Enable auto `[Tab]` command complete by putting the following script into `/etc/bash_completion.d/uuu`:

```bash
_uuu_autocomplete()
{
    COMPREPLY=($(/home/lizhi/source/mfgtools/uuu/uuu $1 $2 $3))
}

complete -o nospace -F _uuu_autocomplete uuu
```

---

## 1.7 L4.9.123_2.3.0_8MM GA

This is the first official BSP release to support UUU. For **L4.9.123_2.3.0_8MM GA** with i.MX8M Mini, see the official release notes.