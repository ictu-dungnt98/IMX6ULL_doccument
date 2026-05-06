# Chapter 5: System Porting and Customization

The previous chapter described how to build a system image that can run on the MYD-Y6ULX development board based on Yocto project, as well as the process of burning the image to the development board.

Because many pins of the MYC-Y6ULX CPU module have multi-function reuse characteristics, there will always be some differences between a base-board based on the CPU module and the MYB-Y6ULX module in actual projects. These differences are mainly reflected in two aspects:

- **Hardware differences** — such as removal of display function, addition of more GPIO/serial ports, or expansion of peripherals through SPI, I2C, USB, etc.
- **System component differences** — HMI-focused applications may need a complete graphics system and Qt library, while background management applications may need more complete network applications and a Python runtime environment.

Because of these differences, system developers need to perform some deletion and migration based on the provided code. This chapter describes the specific process of developing and customizing your own system from the perspective of a system developer.

---

## 5.1 Introduction to meta-myir Layer

The **"layer model"** of the Yocto project is a development model created for embedded and IoT Linux, which distinguishes Yocto from other simple build systems. The layer model supports both collaboration and customization. A layer is a repository of related instruction sets that tell OpenEmbedded what to do with the build system.

The **meta-myir** layer is based on the NXP official `meta-imx` layer and is suitable for the MYD-Y6ULX development board. The layer contains BSP, GUI, release configuration, middleware, application metadata, and recipes. Users can add or remove packages from the BSP by creating a custom Yocto project layer.

### meta-myir Layer Structure

```
meta-myir/
├── EULA.txt
├── meta-bsp/
│   ├── classes
│   ├── conf
│   ├── recipes-bsp
│   ├── recipes-connectivity
│   ├── recipes-core
│   ├── recipes-daemons
│   ├── recipes-devtools
│   ├── recipes-fsl
│   ├── recipes-graphics
│   ├── recipes-kernel
│   ├── recipes-multimedia
│   ├── recipes-myir
│   ├── recipes-security
│   ├── recipes-support
│   ├── recipes-test
│   └── recipes-utils
├── meta-ml/
│   ├── conf
│   ├── recipes-devtools
│   └── recipes-libraries
├── meta-sdk/
│   ├── classes
│   ├── conf
│   ├── dynamic-layers
│   ├── recipes-connectivity
│   ├── recipes-devtools
│   ├── recipes-extended
│   ├── recipes-fsl
│   ├── recipes-graphics
│   ├── recipes-multimedia
│   ├── recipes-sato
│   └── recipes-support
├── README
├── SCR-5.10.9_1.0.0.txt
└── tools/
    ├── myir-setup-release.sh
    ├── readme-bluez.txt
    └── setup-utils.sh

34 directories, 6 files
```

### Table 5-1. meta-myir Layer Content Description

| Source Code and Data | Description |
|---|---|
| `conf` | Development board software configuration resource information |
| `recipes-bsp` | Contains TF-A and U-Boot configuration resources, etc. |
| `recipes-kernel` | Contains Linux kernel resources and third-party firmware resources |
| `recipes-myir` | Contains configuration information for file system scripts and Yocto environment configuration |

> In the process of system porting, focus on: **recipes-bsp** (hardware initialization and system boot), **recipes-kernel** (Linux kernel and driver implementation), and **recipes-app** (application customization).

---

## 5.2 Introduction to Board Level Support Package (BSP)

A Board Level Support Package (BSP) is a collection of information that defines how to support a specific hardware device, device set, or hardware platform. The BSP includes:

- Hardware feature information of the device
- Kernel configuration information
- Any other required hardware drivers

In some cases, BSP contains separately licensed intellectual property (IP) for one or more components, requiring acceptance of an explicit End User License Agreement (EULA). Once the license is accepted, MYIR's development board uses BSP to comply with open source agreement licenses, and the BSP source code will be fully open source.

### Table 5-2. meta-myir IP Project Description

| IP Project | Description |
|---|---|
| `conf` | Development board software configuration resource information |
| `meta-bsp/recipes-bsp` | Contains configuration resources such as U-Boot |
| `meta-bsp/recipes-kernel` | Contains Linux kernel resources and third-party firmware resources |
| `meta-bsp/recipes-myir` | Contains file system configuration information and applications (e.g. HMI v2.0) |

According to the different stages of startup, BSP is divided into **bootloader** and **kernel**:

- **recipes-bsp** — contains U-Boot, mainly implementing core hardware initialization such as DDR, clock, and kernel boot
- **recipes-kernel** — contains Linux kernel and Linux firmware, mainly for kernel configuration and peripheral firmware

---

## 5.3 U-Boot Compilation

U-Boot ("the Universal Boot Loader") is an open-source bootloader used on NXP boards to initialize the platform and load the Linux kernel. It is widely used in embedded systems. For more information, refer to the official site: [http://www.denx.de/wiki/U-Boot/WebHome](http://www.denx.de/wiki/U-Boot/WebHome)

---

### 5.3.1 Get U-Boot Source Code

Use `myir-imx-uboot.tar.gz` directly from the working directory, or download the latest source code:

```bash
git clone https://github.com/MYiR-Dev/myir-imx-uboot.git -b develop_2020.04
```

### Configuration and Compilation

Set the environment on the host machine before building for i.MX6UL SoC:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
```

Compile the source code:

```bash
myir$ cd myir-imx-uboot
myir$ make distclean
myir$ make <config>
myir$ make -j16
```

Replace `<config>` with the appropriate configuration option for your board and boot mode. After compiling, `u-boot-dtb.imx` is generated in the current directory.

### Table 5-3. U-Boot Configuration List

| Configuration | Description |
|---|---|
| `myd_imx6ull_nand_ddr256_defconfig` | MYD-Y6ULY2-V2-256N256D |
| `myd_imx6ull_emmc_defconfig` | MYD-Y6ULY2-V2-4E512D |
| `myd_imx6ul_nand_ddr256_defconfig` | MYD-Y6ULG2-V2-256N256D |
| `myd_imx6ul_emmc_defconfig` | MYD-Y6ULG2-V2-4E512D |

---

### 5.3.2 Use Yocto to Compile U-Boot

The `.bb` file specifying the U-Boot source code location in Yocto:

```
sources/meta-myir/meta-bsp/recipes-bsp/u-boot/u-boot-common.inc
```

```bash
UBOOT_SRC ?= "git://github.com/MYiR-Dev/myir-imx-uboot.git;protocol=https"
SRCBRANCH = "develop_2020.04"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
#SRCREV = "${AUTOREV}"
SRCREV = "2e966da26f1edd6122e4567247a2338de6aa29e0"
```

| Variable | Description |
|---|---|
| `UBOOT_SRC` | U-Boot source code location |
| `SRCBRANCH` | Branch name |
| `SRCREV` | Commit hash — set to `${AUTOREV}` to always use the latest commit |

> If you modify the U-Boot source code, submit the modification, generate a new commit, update `SRCREV` in `u-boot-common.inc`, then recompile.

**Set the environment** (after Yocto exits or is interrupted):

```bash
myir$ source myir-setup-release.sh -b build_imx6ull
```

**Compile:**

```bash
myir$ bitbake u-boot -c clean
myir$ bitbake u-boot -c cleansstate
myir$ bitbake u-boot
```

Output location after Yocto compilation:

```
build_imx6ull/tmp/deploy/images/myd-y6ull14x14/
```

---

### 5.3.3 Configure Yocto to Use Local U-Boot Source Code

By default, `u-boot-common.inc` pulls source code from GitHub. To use a local copy instead, modify the file as follows:

```bash
#UBOOT_SRC ?= "git://github.com/MYiR-Dev/myir-imx-uboot.git;protocol=https"
UBOOT_SRC = "git:////${HOME}/MYD-Y6ULX-devel/04_Sources/myir-imx-uboot;protocol=file"
SRCBRANCH = "develop_2020.04"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
#SRCREV = "${AUTOREV}"
SRCREV = "2e966da26f1edd6122e4567247a2338de6aa29e0"
```

After modification, subsequent Yocto builds will use the local source code.

---

## 5.4 Kernel Compilation

The Linux kernel is a widely used open-source kernel applied to various distribution operating systems. It is used in embedded systems due to its portability, network protocol support, independent module mechanism, MMU, and other rich characteristics.

The i.MX6UL also supports the Linux kernel and has been added to the kernel mainline. For the latest version, check: [https://www.kernel.org](https://www.kernel.org)

MYD-Y6ULX currently supports **Linux kernel version 5.10.9**.

---

### 5.4.1 Get Kernel Source Code

Use `myir-imx-linux.tar.gz` directly from the working directory, or download the latest source code:

```bash
git clone https://github.com/MYiR-Dev/myir-imx-linux.git -b develop_lf-5.10.y
```

---

### 5.4.2 Configuration and Compilation

Set the environment on the host machine before building for i.MX6UL SoC:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
```

Compile the source code:

```bash
myir$ tar -xvf myir-imx-linux.tar.gz
myir$ cd myir-imx-linux
myir$ make distclean
myir$ make myd_y6ulx_defconfig
myir$ make zImage dtbs -j16
```

After compiling:
- Kernel image `zImage` → `arch/arm/boot/`
- DTB files → `arch/arm/boot/dts/`

### Table 5-4. DTB File List

| DTB File | Description |
|---|---|
| `myd-y6ull-emmc.dtb` | MYD-Y6ULY2-V2-4E512D |
| `myd-y6ull-gpmi-weim.dtb` | MYD-Y6ULY2-V2-256N256D |
| `myd-y6ul-emmc.dtb` | MYD-Y6ULG2-V2-4E512D |
| `myd-y6ul-gpmi-weim.dtb` | MYD-Y6ULG2-V2-256N256D |

---

### 5.4.3 Use Yocto to Compile Kernel

The `.bb` file specifying the kernel source code location in Yocto:

```
sources/meta-myir/meta-bsp/recipes-kernel/linux/linux-imx_5.10.bb
```

```bash
KERNEL_BRANCH ?= "develop_lf-5.10.y"
LOCALVERSION = "-1.0.0"
KERNEL_SRC ?= "git://github.com/MYiR-Dev/myir-imx-linux.git;protocol=https"
SRC_URI = "${KERNEL_SRC};branch=${KERNEL_BRANCH}"
#SRCREV = "${AUTOREV}"
SRCREV = "7c0cb551c77eaa18f4b0333fd5f55c147dad7557"
```

| Variable | Description |
|---|---|
| `KERNEL_SRC` | Kernel source code location |
| `KERNEL_BRANCH` | Branch name |
| `SRCREV` | Commit hash — set to `${AUTOREV}` to always use the latest commit |

**Set the environment** (after Yocto exits or is interrupted):

```bash
myir$ source myir-setup-release.sh -b build_imx6ull
```

**Compile:**

```bash
myir$ bitbake linux-imx -c clean
myir$ bitbake linux-imx -c cleansstate
myir$ bitbake linux-imx
```

Output location after Yocto compilation:

```
build_imx6ull/tmp/deploy/images/myd-y6ull14x14/
```

---

### 5.4.4 Configure Yocto to Use Local Kernel Source Code

By default, `linux-imx_5.10.bb` pulls source code from GitHub. To use a local copy instead, modify the file as follows:

```bash
KERNEL_BRANCH ?= "develop_lf-5.10.y"
LOCALVERSION = "-1.0.0"
#KERNEL_SRC ?= "git://github.com/MYiR-Dev/myir-imx-linux.git;protocol=https"
KERNEL_SRC = "git:////${HOME}/MYD-Y6ULX-devel/04_Sources/myir-imx-linux;protocol=file"
SRC_URI = "${KERNEL_SRC};branch=${KERNEL_BRANCH}"
#SRCREV = "${AUTOREV}"
SRCREV = "7c0cb551c77eaa18f4b0333fd5f55c147dad7557"
```

In `KERNEL_SRC`, modify the path to point to the kernel source code extracted in the working directory. After modification, subsequent Yocto builds will use the local source code.