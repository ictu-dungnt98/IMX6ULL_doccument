# Chapter 2: Development Environment Setup

This chapter mainly introduces some software and hardware environment required in the development process, including the necessary development host environment, necessary software tools, code and resource acquisition, etc.

---

## 2.1 Hardware Environment

### Necessary Accessories

- 12V power adapter
- SD card no less than 4GB
- USB to TTL debugging cable (used for debugging serial port) — **note:** use 3.3V level

---

### Startup Settings

This section mainly introduces the startup method of the development board so that users can better choose the startup method.

**Table 2-1. Boot Mode Selector Switch**

| BOOT MODE SWITCH (B1/B2/B3/B4) | Boot Form                    |
|--------------------------------|------------------------------|
| OFF/OFF/ON/OFF                 | Boot from eMMC               |
| OFF/ON/ON/OFF                  | Boot from NAND Flash         |
| ON/ON/ON/OFF                   | Boot from SD Card (eMMC board) |
| ON/OFF/ON/OFF                  | Boot from SD Card (NAND board) |
| X/X/OFF/ON                     | USB Download                 |

---

### Serial Port Configuration

Connect the USB to TTL cable to the debugging serial port **JP1** correctly, connect the USB end to the PC, and use the debugging software to configure the PC serial port as follows:

**Table 2-2. Debug Port Settings**

| Baud Rate | Data Bit | Stop Bit | Parity | Other |
|-----------|----------|----------|--------|-------|
| 115200    | 8        | 1        | No     | No    |

Use a **12V power adapter** to connect to the **J22** interface of the development board. It can start normally after power on. The startup information will be printed out under serial debugging on the PC side.

> **Note:** The default system username is `root` and the password is **blank**.

---

## 2.2 Software Environment

This section describes how to deploy the i.MX6UL development environment. By reading this section, you will learn about the installation and use of hardware and software tools, and you can quickly deploy the relevant development environment and prepare for subsequent development and debugging.

---

### 2.2.1 Get Information

Download the development board materials before setting up the environment. For detailed information about the development materials, please refer to *MYD-Y6ULX SDK Release Notes*.

The download address of the development board data is as follows *(the data will be updated from time to time, please download the latest version)*:

```
http://d.myirtech.com/MYD-Y6ULX/
```

---

### 2.2.2 Setting Up a Compilation Environment

#### Host Hardware

To get the Yocto Project expected behavior in a Linux Host Machine, the packages and utilities described below must be installed. An important consideration is the hard disk space required in the host machine.

- **Minimum disk space:** 160 GB (enough to compile all backends together)
- **CPU:** More than dual-core recommended
- **RAM:** 8 GB or higher
- Supported host types: physical machine with Linux, or virtual machine running Linux

#### Host Operating System

There are many options for the host operating system used to build the Yocto project. Please refer to the official Yocto instructions for details:

```
https://docs.yoctoproject.org/
```

Generally, the following Linux distributions can be used: Fedora, openSUSE, Debian, Ubuntu, RHEL, or CentOS.

> **Recommended:** Ubuntu 20.04 64-bit Desktop. All subsequent development in this guide is based on this system.

#### Prerequisite Package Installation

```bash
myir$ sudo apt-get update
myir$ sudo apt-get install gawk wget git-core diffstat unzip texinfo \
  gcc-multilib build-essential chrpath socat cpio python python3 \
  python3-pip python3-pexpect xz-utils debianutils iputils-ping \
  python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm
```

#### Create a Working Directory

Create a working directory to facilitate the creation of a unified environment variable path. Copy the product CD-ROM source code to the working directory, while setting the `DEV_ROOT` variable to enable the follow-up step path access.

```bash
myir$ mkdir -p ~/MYD-Y6ULX-devel
myir$ export DEV_ROOT=~/MYD-Y6ULX-devel
myir$ cp -r /02_Images $DEV_ROOT
myir$ cp -r /03_Tools $DEV_ROOT
myir$ cp -r /04_Sources $DEV_ROOT
```

---

### 2.2.3 Install the SDK Customized by MYIR

After using Yocto to build the system image, we can also use Yocto to build a set of extensible SDK. The CD image provided by MYIR contains a compiled SDK package, located in the `03_tools/Tools_chain/` directory.

This SDK includes:
- An independent cross development toolchain
- `qmake` and sysroot of the target platform
- Libraries and header files required for QT application development

Users can directly use this SDK to establish an independent development environment and compile bootloader, kernel, or their own applications.

#### View Script File

Go to the SDK directory to find the installation scripts.

**Table 2-3. Toolchain Files**

| Toolchain File Name | Description |
|---|---|
| `fsl-imx-fb-glibc-x86_64-meta-toolchain-cortexa7t2hf-neon-myd-y6ull14x14-toolchain-5.10-gatesgarth.sh` | meta-toolchain |
| `fsl-imx-fb-glibc-x86_64-myir-image-full-cortexa7t2hf-neon-myd-y6ull14x14-toolchain-5.10-gatesgarth.sh` | myir-image-full |
| `fsl-imx-fb-glibc-x86_64-myir-image-core-cortexa7t2hf-neon-myd-y6ull14x14-toolchain-5.10-gatesgarth.sh` | myir-image-core |

#### Run the SDK Installation Script

The SDK is installed in the `/opt/` directory by default. Users can also choose an appropriate directory according to the prompts:

```bash
myir@myir-O-E-M:/home/hjx/sdk$ sudo ./fsl-imx-fb-glibc-x86_64-myir-image-full-cortexa7t2hf-neon-myd-y6ull14x14-toolchain-5.10-gatesgarth.sh

NXP i.MX Release Distro SDK installer version 5.10-gatesgarth
=============================================================
Enter target directory for SDK (default: /opt/fsl-imx-fb/5.10-gatesgarth): /opt/test5.10/
You are about to install the SDK to "/opt/test5.10/". Proceed [Y/n]? y
Extracting SDK...done
Setting it up...done
SDK has been successfully set up and is ready to be used.
Each time you wish to use the SDK in a new shell session, you need to source the environment setup script e.g.
$ . /opt/test5.10/environment-setup-cortexa7t2hf-neon-poky-linux-gnueabi
```

#### Test SDK

Initialize cross-compilation via SDK and ensure that the environment is correctly set up:

```bash
myir@myir-O-E-M:/home/hjx/sdk$ source /opt/test5.10/environment-setup-cortexa7t2hf-neon-poky-linux-gnueabi

myir@myir-O-E-M:/home/hjx/sdk$ $CC -v
Using built-in specs.
COLLECT_GCC=arm-poky-linux-gnueabi-gcc
COLLECT_LTO_WRAPPER=/opt/test5.10/sysroots/x86_64-pokysdklinux/usr/libexec/arm-poky-linux-gnueabi/gcc/arm-poky-linux-gnueabi/10.2.0/lto-wrapper
gcc version 10.2.0 (GCC)
```

> **Note:** The SDK provided by MYIR includes not only the cross toolchain, but also Qt library, `qmake`, and other resources needed to develop QT applications. These are the basis for the subsequent application development and debugging with QT Creator.