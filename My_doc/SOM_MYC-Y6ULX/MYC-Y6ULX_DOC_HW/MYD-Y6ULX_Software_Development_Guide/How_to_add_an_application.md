# Chapter 7: Application Development and Deployment

The porting of Linux applications is usually divided into two stages: **development & debugging** and **production deployment**.

- In the **development and debugging** stage, thanks to the SDK customized by MYIR (refer to Section 2.3), it is easy to develop and debug applications in a standalone environment.
- In the **production deployment** stage, thanks to the Yocto project, users only need to write a recipe file for the tested application and place the source code in the corresponding directory. Then use the `bitbake` command to rebuild the image and automatically package the application into the system.

---

## 7.1 Makefile-Based Project

A Makefile defines a series of compilation rules to guide the compilation of source code. With a single `make` command, the whole project compiles automatically, and only changed source files are recompiled. Makefile is widely used in Linux kernel, driver, and application development.

### Makefile Rules

```makefile
target ... : prerequisites ...
    command
```

| Term | Description |
|---|---|
| `target` | An object file, an executable file, or a label |
| `prerequisites` | Files needed to generate the target |
| `command` | The command that `make` needs to execute |
| `CC` | Name of the C compiler |
| `CXX` | Name of the C++ compiler |
| `clean` | Conventional cleanup target |

### Example: Generic Makefile Template

```makefile
TARGET = $(notdir $(CURDIR))
objs := $(patsubst %c, %o, $(shell ls *.c))

$(TARGET)_test: $(objs)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) -c -o $@ $<

clean:
	rm -f $(TARGET)_test *.all *.o
```

### Example Source Files

**`main.c`**
```c
#include "module.h"

void sample_func();

int main()
{
    sample_func();
    return 0;
}
```

**`module.h`**
```c
#include <stdio.h>

void sample_func();
```

**`module.c`**
```c
#include "module.h"

void sample_func()
{
    printf("Hello World!");
    printf("\n");
}
```

### Build and Run

Set up the toolchain environment:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
```

Create the Makefile:

```makefile
# CC="gcc"
all: main.o module.o
	${CC} main.o module.o -o target_bin

main.o: main.c module.h
	${CC} -I . -c main.c

module.o: module.c module.h
	${CC} -I . -c module.c

clean:
	rm -rf *.o
	rm target_bin
```

Execute `make` to compile:

```bash
myir$ make
```

Copy the executable to the board and run:

```bash
# ./target_bin
Hello World!
```

> **Note:** If you use the cross toolchain to build `target_bin`, the architecture of the building host is different from the target machine — the binary must be run on the target device, not the host.

---

## 7.2 Application Based on Qt

Qt is a cross-platform graphics application development framework used on different sizes of devices and platforms. **MYD-Y6ULX uses Qt version 5.15** for application development. It is recommended to use the **QtCreator** integrated development environment to develop Qt applications under Linux PC and automatically cross-compile to the ARM architecture.

### 1) QtCreator Installation

Get the QtCreator installation package from the Qt website or MYIR official package:

```
http://download.qt.io/development_releases/qtcreator/
```

Install by executing the binary directly:

```bash
./qt-creator-opensource-linux-x86_64-4.1.0-rc1.run
```

For detailed installation and configuration, refer to *MYD-Y6ULX QT Application Development Notes* or the official website: [https://www.qt.io/product/development-tools](https://www.qt.io/product/development-tools)

### 2) Compiling and Running MEasy HMI 2.0

MEasy HMI 2.0 is a Qt5-based human-machine interface framework developed by Shenzhen Myir Technology Co., Ltd. It uses QML and C++ mixed programming — QML for efficient UI building, C++ for business logic and complex algorithms.

The source code (`mxapp2.tar.gz`) is located in the `04_Sources/` directory and can be compiled and debugged remotely through QtCreator. For more details, refer to *MYD-Y6ULX QT Application Development Notes* and `MEasy+HMI2.0+Development+Guide.pdf`.

---

## 7.3 Automatic Application Startup at Boot Time

### 7.3.1 Application Configuration in Yocto

Applications can be configured to start automatically at boot using Yocto recipes. This section uses the **proftpd** FTP service (open source, version 1.3.6) as an example to illustrate how to build a production image containing a specific application.

Source code for each version is at: `ftp://ftp.proftpd.org/distrib/source/`

#### Step 1: Check if Recipe Already Exists

Before writing a new recipe, check whether it already exists in the source code repository:

```bash
PC $ bitbake -s | grep proftpd
proftpd    :1.3.6-r0
```

> **Note:** Before executing the `bitbake` command, make sure the environment variable setup script has been executed. Refer to Chapter 3 for details.

You can also search for existing recipes on the OpenEmbedded official layer index:
[http://layers.openembedded.org/layerindex/branch/master/layers/](http://layers.openembedded.org/layerindex/branch/master/layers/)

For writing new recipes, refer to the Yocto Project mega-manual:
[https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#new-recipe-writing-a-new-recipe](https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#new-recipe-writing-a-new-recipe)

#### Step 2: Compile proftpd with BitBake

```bash
PC $ bitbake proftpd
```

#### Step 3: Package proftpd into the File System

Add the following line to `conf/local.conf`:

```bash
IMAGE_INSTALL_append = "proftpd"
```

#### Step 4: Rebuild the File System

```bash
PC $ bitbake myir-image-full
```

#### Step 5: Verify the Service

After burning the new image, check whether the service is running:

```bash
# ps -axu | grep proftpd
nobody  584  0.0  0.3  3032  1344  ?  Ss  01:51  0:00  proftpd: (accepting connections)
root   1713  0.0  0.0  1776   336  pts/0  S+  01:59  0:00  grep proftpd
```

---

### FTP Account Settings

FTP clients support three login account types:

**Anonymous Account:** Username is `ftp`, no password required. Users can view `/var/lib/ftp/` with no write permission by default. Create the directory using a `bbappend` recipe to avoid modifying the `meta-openembedded` layer:

```bash
# proftpd_1%.bbappend
do_install_append() {
    install -m 755 -d ${D}/var/lib/${FTPUSER}
    chown ftp:ftp ${D}/var/lib/${FTPUSER}
}
```

Place the file in `recipes-daemons/proftpd/` under the `meta-myir` layer, then rebuild the image.

**Ordinary Account:** Use `useradd` and `passwd` on the target machine to create a normal user. To include ordinary users when packaging images, refer to:
[https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#ref-classes-useradd](https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#ref-classes-useradd)

**Root Account:** To enable root FTP login, modify `/etc/proftpd.conf` and add:

```
RootLogin on
```

Then restart the service:

```bash
# systemctl restart proftpd
```

> **Note:** Enabling root login is for testing purposes only. For more configuration, refer to: [http://www.proftpd.org/docs/example-conf.html](http://www.proftpd.org/docs/example-conf.html)

---

### 7.3.2 Application Service Auto-Start at Boot Time

The proftpd recipe is located at:

```
sources/meta-openembedded/meta-networking/recipes-daemons/proftpd/
```

Directory structure:

```
├── files/
│   ├── basic.conf.patch
│   ├── build_fixup.patch
│   ├── close-RequireValidShell-check.patch
│   ├── contrib.patch
│   ├── default
│   ├── proftpd-basic.init
│   └── proftpd.service
└── proftpd_1.3.6.bb

1 directory, 8 files
```

| File | Description |
|---|---|
| `proftpd_1.3.6.bb` | Recipe for building proftpd service |
| `proftpd.service` | Auto-start service at boot time |
| `proftpd-basic.init` | Start script for proftpd |

#### Recipe: SRC_URI Definition

```bash
SRC_URI = "ftp://ftp.proftpd.org/distrib/source/${BPN}-${PV}.tar.gz \
           file://basic.conf.patch \
           file://proftpd-basic.init \
           file://default \
           file://close-RequireValidShell-check.patch \
           file://contrib.patch \
           file://build_fixup.patch \
           file://proftpd.service"
```

#### Recipe: do_install Task

```bash
FTPUSER = "ftp"
FTPGROUP = "ftp"

do_install() {
    oe_runmake DESTDIR=${D} install
    rmdir ${D}${libdir}/proftpd ${D}${datadir}/locale
    [ -d ${D}${libexecdir} ] && rmdir ${D}${libexecdir}
    sed -i '/ *User[ \t]*/s/ftp/${FTPUSER}/' ${D}${sysconfdir}/proftpd.conf
    sed -i '/ *Group[ \t]*/s/ftp/${FTPGROUP}/' ${D}${sysconfdir}/proftpd.conf
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/proftpd-basic.init ${D}${sysconfdir}/init.d/proftpd
    install -d ${D}${sysconfdir}/default
    install -m 0755 ${WORKDIR}/default ${D}${sysconfdir}/default/proftpd
    mkdir -p ${D}/home/${FTPUSER}/pub/
    chown -R ${FTPUSER}:${FTPGROUP} ${D}/home/${FTPUSER}/pub
    install -d ${D}/${systemd_unitdir}/system
    install -m 644 ${WORKDIR}/proftpd.service ${D}/${systemd_unitdir}/system
}
```

For more information about install tasks, refer to:
[https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#ref-tasks](https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#ref-tasks)

#### Enable Auto-Start with systemd

To run the application service at boot, set the `SYSTEMD_AUTO_ENABLE` variable in the recipe:

```bash
SYSTEMD_AUTO_ENABLE_${PN} = "enable"
```

The target machine uses **systemd** as the initialization management subsystem (PID 1). For configuring systemd under Yocto project, refer to:
[https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#selecting-an-initialization-manager](https://www.yoctoproject.org/docs/3.1.1/mega-manual/mega-manual.html#selecting-an-initialization-manager)

#### systemd Service File: proftpd.service

```ini
[Unit]
Description=proftpd Daemon
After=network.target

[Service]
Type=forking
ExecStart=@SBINDIR@/proftpd -c @SYSCONFDIR@/proftpd.conf
StandardError=syslog

[Install]
WantedBy=default.target
```

| Directive | Description |
|---|---|
| `After` | Service starts after the network service is up |
| `Type=forking` | Process forks and parent exits; use with `PIDFile=` for tracking |
| `ExecStart` | The program to start and its parameters |

For more systemd information: [https://wiki.archlinux.org/index.php/systemd](https://wiki.archlinux.org/index.php/systemd)

> **Recommendation:** Place your own custom recipes in `sources/meta-myir/meta-bsp/recipes-myir/`.

---

## 7.4 Qt Application Development

MYD-Y6ULX uses **Qt 5.15** for application development with **QtCreator** IDE for cross-compilation to the ARM architecture. This chapter uses the Yocto-built SDK as the cross-compilation system.

> Before starting, complete the Yocto build process in Chapter 3 (or use the pre-compiled SDK from the CD), and install the application SDK development tools.

---

### 7.4.1 Install QtCreator

```bash
$ cd $DEV_ROOT
$ chmod a+x 03_Tools/qt-opensource-linux-x64-5.9.4.run
$ sudo 03_Tools/Qt/qt-opensource-linux-x64-5.9.4.run
```

Keep clicking **Next** to complete. The default installation directory is `/opt/`.

After installation, add the Yocto SDK environment to QtCreator by modifying `/opt/qtcreator-5.9.4/Tools/QtCreator/bin/qtcreator.sh` — add the following line **before** `#! /bin/sh`:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7t2hf-neon-poky-linux-gnueabi

#! /bin/sh
# Use this script if you add paths to LD_LIBRARY_PATH
# that contain libraries that conflict with the
# libraries that Qt Creator depends on.
```

Launch QtCreator from terminal using the script:

```bash
myir$ /opt/qtcreator-5.9.4/Tools/QtCreator/bin/qtcreator.sh &
```

---

### 7.4.2 Configure QtCreator

The following configuration items need to be set in **Tools → Options → Build & Run**:

#### 1) Configure GCC Compiler

- Go to **Compilers** tab → click **Add → GCC → C**
- **Name:** `MYDY6ULx-GCC`
- **Compiler path:**
  ```
  /opt/test5.10/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gcc
  ```
- Click **Apply**

#### 2) Configure G++ Compiler

- Click **Add → GCC → C++**
- **Name:** `MYDY6ULx-GCC++`
- **Compiler path:**
  ```
  /opt/test5.10/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-g++
  ```
- Click **Apply**

#### 3) Configure Qt Version

- Go to **Qt Versions** tab → click **Add...**
- Select qmake at:
  ```
  /opt/test5.10/sysroots/x86_64-pokysdk-linux/usr/bin/qmake
  ```
- **Version name:** `Qt %{Qt:Version} (System)`
- Click **Apply**

#### 4) Configure Debugger

- Go to **Debuggers** tab → click **Add...**
- **Name:** `MYD-Y6ULX-DEBUG`
- **Path:**
  ```
  /opt/test5.10/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gdb
  ```

#### 5) Configure Device

- Go to **Devices** (left sidebar) → click **Add... → Generic Linux Device**
- **Name:** `MYDY6ULx Board`
- **Host name:** IP address of the development board
- **Username:** `root`
- Click **Apply**

#### 6) Create Kit

- Go to **Kits** tab → configure as follows:

| Field | Value |
|---|---|
| Name | `MYD-Y6ULX` |
| Device | `MYDY6ULx Board` |
| Sysroot | `/opt/test5.10/sysroots` |
| Compiler (C) | `MYDY6ULx-GCC` |
| Compiler (C++) | `MYDY6ULx-GCC++` |
| Qt version | `Qt 5.15.0 (System)` |
| Qt mkspec | `linux-oe-g++` |

Click **Apply** then **OK**.

---

### 7.4.3 Test Qt Application

**Step 1:** Create a new Qt project via **File → New File or Project**. Set the project name to `Y6ULX_TEST`.

**Step 2:** After the project opens, select the **MYD-Y6ULX** kit to complete the creation.

**Step 3:** Click **Build → Build Project Y6ULX_TEST** to compile. The compilation output appears at the bottom.

After building, the compiled binary is stored in the `build-Y6ULX_TEST-MYD_Y6ULX-Debug/` directory. Verify the architecture:

```bash
# file Y6ULX_TEST
Y6ULX_TEST: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV),
dynamically linked, interpreter /lib/ld-, for GNU/Linux 3.2.0, not stripped
```

Copy the binary to the development board and run:

```bash
# ./Y6ULX_TEST --platform linuxfb
```

After running, the Qt window interface will appear on the LCD screen.