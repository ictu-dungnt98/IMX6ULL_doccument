# MYD-Y6ULX Software Development Guide

**Document:** MYIR-MYD-Y6ULX-SW-DG-EN-L5.10.9  
**Kernel Version:** Linux 5.10.9  
**Board:** MYD-Y6ULX Series Development Board

---

## Table of Contents

| Chapter | Title | Description |
|---------|-------|-------------|
| [Chapter 1](MYD-Y6ULX_Chapter1_Overview.md) | Overview | Introduction, software resources, document resources |
| [Chapter 2](MYD-Y6ULX_Chapter2_Environment_Setup.md) | Development Environment Setup | Hardware environment, boot settings, SDK installation |
| [Chapter 3](MYD-Y6ULX_Chapter3_Yocto_Build.md) | Building the Yocto System Image | Source code, build process, SDK build |
| [Chapter 4](MYD-Y6ULX_Chapter4_Flashing.md) | Flashing the System Image | UUU tool, SD card flashing |
| [Chapter 5](MYD-Y6ULX_Chapter5_System_Porting.md) | System Porting and Customization | meta-myir layer, BSP, U-Boot, Kernel compilation |
| [Chapter 6](MYD-Y6ULX_Chapter6_GPIO_Control.md) | Hardware Adaptation and GPIO Control | Device tree, pin configuration, GPIO in kernel/userspace |
| [Chapter 7](MYD-Y6ULX_Chapter7_App_Development.md) | Application Development and Deployment | Makefile, Qt, Yocto recipes, auto-start at boot |

---

## Quick Reference

### Development Environment
- Host OS: **Ubuntu 20.04 64-bit**
- Minimum disk: **160 GB**
- RAM: **8 GB or higher**
- SDK path: `/opt/test5.10/`

### Source Code Repositories

| Component | Repository |
|-----------|-----------|
| U-Boot | `https://github.com/MYiR-Dev/myir-imx-uboot.git` |
| Linux Kernel | `https://github.com/MYiR-Dev/myir-imx-linux.git` |
| Yocto Manifest | `https://github.com/MYiR-Dev/myir-imx-manifest.git` |
| Board Data | `http://d.myirtech.com/MYD-Y6ULX/` |

### Common BitBake Commands

```bash
# Build full image with Qt
bitbake myir-image-full

# Build core image (no GUI)
bitbake myir-image-core

# Build SDK
bitbake -c populate_sdk myir-image-full

# Compile U-Boot only
bitbake u-boot

# Compile Kernel only
bitbake linux-imx
```

### Boot Mode DIP Switch (SW1)

| B1/B2/B3/B4 | Boot Mode |
|-------------|-----------|
| OFF/OFF/ON/OFF | eMMC |
| OFF/ON/ON/OFF | NAND Flash |
| ON/ON/ON/OFF | SD Card (eMMC board) |
| ON/OFF/ON/OFF | SD Card (NAND board) |
| X/X/OFF/ON | USB Download |

---

## Related Documents

- MYD-Y6ULX SDK Release Notes
- MYD-Y6ULX Linux Software Evaluation Guide
- MYD-Y6ULX QT Application Development Notes
- MEasy HMI 2.0 Development Guide
- MYC-Y6ULX CPU Module Product Manual