# Chapter 6: Hardware Adaptation and GPIO Control

In order to adapt to the new hardware platform, it is necessary to know what resources are provided by the MYD-Y6ULX development board. For specific information, please refer to *MYD-Y6ULX SDK Release Notes*. Users also need to refer to the CPU chip manual and the product manual of the MYC-Y6ULX module to have a detailed understanding of CPU pin definitions and performance, and to correctly configure and use these pins according to actual functions.

---

## 6.1 How to Create Your Device Tree

### 6.1.1 Board Level Device Tree

Users can create their own device tree in the BSP source code. Generally, users do not need to modify U-Boot in the bootloader — you only need to adjust the Linux kernel device tree according to the actual hardware resources.

**Table 6-1. MYD-Y6ULX Device Tree List**

| Project | Device Tree | Description |
|---|---|---|
| **U-Boot** | `imx6ull-y2.dtsi` / `imx6ul-g2.dtsi` | Peripheral resource device tree |
| | `myb-imx6ul-14x14-base.dts` | Basic dts of MYC-Y6ULX-G2 |
| | `myb-imx6ull-14x14-base.dts` | Basic dts of MYC-Y6ULX-Y2 |
| | `myb-imx6ul-14x14-gpmi-weim.dts` | MYC-Y6ULX-G2 NAND board dts |
| | `myb-imx6ul-14x14-emmc.dts` | MYC-Y6ULX-G2 eMMC board dts |
| | `myb-imx6ull-14x14-gpmi-weim.dts` | MYC-Y6ULX-Y2 NAND board dts |
| | `myb-imx6ull-14x14-emmc.dts` | MYC-Y6ULX-Y2 eMMC board dts |
| **Kernel** | `myd_y6ulx_defconfig` | Kernel configuration |
| | `myb-imx6ul-14x14.dtsi` | MYC-Y6ULX public part dtsi |
| | `myb-imx6ul-14x14-base.dts` | MYC-Y6ULX-G2 basic dts |
| | `myb-imx6ull-14x14-base.dts` | MYC-Y6ULX-Y2 basic dts |
| | `myd-y6ul-emmc.dts` | MYC-Y6ULX-G2 eMMC board dts |
| | `myd-y6ul-gpmi-weim.dts` | MYC-Y6ULX-G2 NAND board dts |
| | `myd-y6ull-emmc.dts` | MYC-Y6ULX-Y2 eMMC board dts |
| | `myd-y6ull-gpmi-weim.dts` | MYC-Y6ULX-Y2 NAND board dts |

---

### 6.1.2 Add Your Board Level Device Tree

A device tree is a tree data structure with nodes that describe the devices in a system. Each node has property/value pairs that describe the characteristics of the device being represented. Rather than hard-coding every detail of a device into an operating system, many aspects of the hardware can be described in a data structure that is passed to the OS at boot time — describing hardware that cannot be located by probing.

#### Step 1: Add Board Level Device Tree File

Go to the kernel device tree directory `arch/arm/boot/dts`, find the existing device tree files, and add your own board level device tree file (e.g. `myb-imx6ul-14x14-base-xxx.dts`):

```bash
# Path: arch/arm/boot/dts
myir$ cd myir-imx-linux/arch/arm/boot/dts

myir$ ls -l myb-imx6ul*dts
-rw-rw-r-- 1 myir myir  274 myb-imx6ul-14x14-base.dts
-rw-rw-r-- 1 myir myir 4460 myb-imx6ull-14x14-base.dts

myir$ ls -l myd*dts
-rw-rw-r-- 1 myir myir  485 myd-y6ul-emmc.dts
-rw-rw-r-- 1 myir myir 1822 myd-y6ul-gpmi-weim.dts
-rw-rw-r-- 1 myir myir  512 myd-y6ull-emmc.dts
-rw-rw-r-- 1 myir myir 1756 myd-y6ull-gpmi-weim.dts
```

Include the required device tree header files in your newly created board level device tree:

```dts
// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2015 Freescale Semiconductor, Inc.

/ {
    chosen {
        stdout-path = &uart1;
    };

    memory@80000000 {
        device_type = "memory";
        reg = <0x80000000 0x20000000>;
    };

    reserved-memory {
        #address-cells = <1>;
        #size-cells = <1>;
        ranges;

        linux,cma {
            compatible = "shared-dma-pool";
            reusable;
            size = <0x8000000>;
            linux,cma-default;
        };
    };
    ......
};
```

> For more detailed header file inclusion, refer to the reference device tree file: `myb-imx6ull-14x14-base.dts`.

#### Step 2: Add Device Tree Entry to Makefile

After adding the new device tree source file, add the DTB compilation entry in the `Makefile` under the same directory:

```makefile
# File: arch/arm/boot/dts/Makefile
dtb-$(CONFIG_SOC_IMX6UL) += \
    ......
    myb-imx6ul-14x14-base.dtb \
    myd-y6ul-gpmi-weim.dtb \
    myd-y6ul-emmc.dtb \
    myb-imx6ul-14x14-base-xxx.dtb  # <-- your new entry
    ......
```

After adding the device tree, fill it according to your hardware resources and compile the DTB file (refer to Section 5.4 for compilation).

> **Recommendation:** Rather than creating a brand new device tree, it is recommended to modify the MYIR device tree directly, as adding a new device tree also requires modifying the U-Boot loading filename and updating Yocto configuration files and metadata.

---

## 6.2 How to Configure Function Pins According to Your Hardware

### 6.2.1 GPIO Pin Configuration

GPIO (General Purpose Input/Output) is a very important resource in embedded devices. It can output high/low level or read the status of pins. The i.MX6UL devices encapsulate a large number of peripheral controllers, which use GPIO multiplexing to implement more complex functions.

A GPIO pin can be configured as either a major function or an alternate function:
- If the pin is connected to an external **UART transceiver** → configure as **primary function**
- If the pin is connected to an external **Ethernet controller for interrupt** → configure as **GPIO input with interrupt enabled**

GPIO pin configuration on i.MX6UL is done using **MX6 Pins Tool** software or manually by referring to the datasheet.

#### 1) Configure Peripherals Using MX6 Pins Tool

The MX6 Pins Tool makes pin configuration easier through an intuitive UI and generates C code for use in any C/C++ application. It can also create a device tree summary include (`.dtsi`) file and export reports in CSV format.

Official download: [https://www.nxp.com/design/designs/pins-tool-for-i-mx-application-processors:PINS-TOOL-IMX](https://www.nxp.com/design/designs/pins-tool-for-i-mx-application-processors:PINS-TOOL-IMX)

Select a PIN in the tool and check a function to generate the corresponding dts code in the right panel.

#### 2) Configure GPIO in the Device Tree

This example uses **J14 PIN5** (`MX6UL_PAD_UART3_TX_DATA__GPIO1_IO24`) as the test GPIO.

File: `myir-imx-linux/arch/arm/boot/dts/myb-imx6ul-14x14.dtsi`

```dts
gpioctr_device {
    compatible = "myir,gpioctr";
    status = "okay";
    gpioctr-gpios = <&gpio1 24 0>;
};

reg_can_3v3: regulator@0 {
    compatible = "regulator-fixed";
    reg = <0>;
    regulator-name = "can-3v3";
    regulator-min-microvolt = <3300000>;
    regulator-max-microvolt = <3300000>;
};

&iomuxc {
    pinctrl-names = "default";
    pinctrl-0 = <&BOARD_InitPins>;

    imx6ul-board {
        BOARD_InitPins: BOARD_InitPinsGrp {
            fsl,pins = <
                MX6UL_PAD_CSI_DATA03__GPIO4_IO24       0x000010B0
                MX6UL_PAD_JTAG_TDO__GPIO1_IO12         0x000030B1
                MX6UL_PAD_LCD_DATA16__GPIO3_IO21        0x000010B0
                MX6UL_PAD_LCD_DATA17__GPIO3_IO22        0x000010B0
                MX6UL_PAD_UART1_RTS_B__GPIO1_IO19      0x000010B0
                MX6UL_PAD_UART3_CTS_B__GPIO1_IO26      0x000010B0
                MX6UL_PAD_UART3_RTS_B__GPIO1_IO27      0x000010B0
                MX6UL_PAD_UART3_RX_DATA__UART3_DCE_RX  0x000010B0
                MX6UL_PAD_UART3_TX_DATA__GPIO1_IO24    0x000030B0
            >;
        };
    };
};
```

---

## 6.3 How to Use Your Own Configured Pins

### 6.3.1 How to Use GPIO in U-Boot

#### 1) GPIO Control Through U-Boot Command

In the U-Boot shell, use commands directly to control GPIO. For example, to control `gpio1_24`:

```bash
# Set GPIO high
=> gpio set 24 1
gpio: pin 24 (gpio 24) value is 1

# Set GPIO low
=> gpio clear 24 1
gpio: pin 24 (gpio 24) value is 0
```

#### 2) GPIO Control Through Code

File: `myir-imx-uboot/board/myir/myd_imx6ull_14x14/myd_imx6ull14x14.c`

```c
int board_init(void)
{
    /* LCD Power */
    imx_iomux_v3_setup_multiple_pads(lcd_pwr_pads, ARRAY_SIZE(lcd_pwr_pads));
    gpio_request(IMX_GPIO_NR(3, 4), "power");
    gpio_direction_output(IMX_GPIO_NR(3, 4), 1);
    ......
}
```

#### 3) GPIO Control Through Device Tree (U-Boot)

Define IO resource nodes in the device tree and implement IO functions in code (e.g. WiFi & BT power reset control):

```dts
// File: arch/arm/dts/myb-imx6ul-14x14-base.dts
&fec2 {
    pinctrl-names = "default";
    pinctrl-0 = <&pinctrl_enet2>;
    phy-mode = "rmii";
    phy-handle = <&ethphy1>;
    phy-reset-gpios = <&gpio5 6 GPIO_ACTIVE_LOW>;
    phy-reset-duration = <26>;
    phy-reset-post-delay = <20>;
    status = "okay";

    mdio {
        #address-cells = <1>;
        #size-cells = <0>;
        ethphy0: ethernet-phy@0 {
            compatible = "ethernet-phy-ieee802.3-c22";
            reg = <0>;
        };
    };
};
```

```c
// file: uboot/drivers/net/fec_mxc.c
static void fec_gpio_reset(struct fec_priv *priv)
{
    debug("fec_gpio_reset: fec_gpio_reset(dev)\n");
    if (dm_gpio_is_valid(&priv->phy_reset_gpio)) {
        dm_gpio_set_value(&priv->phy_reset_gpio, 1);
        mdelay(priv->reset_delay);
        dm_gpio_set_value(&priv->phy_reset_gpio, 0);
        if (priv->reset_post_delay)
            mdelay(priv->reset_post_delay);
    }
}
```

---

### 6.3.2 How to Use GPIO in Kernel Driver

#### 1) Independent GPIO Driver (gpioctr.c)

Based on the GPIO device node defined in Section 6.2.1, the following kernel driver controls GPIO (set J14-PIN5 to high or low):

```c
// gpioctr.c
#include <linux/module.h>
#include <linux/of_device.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/miscdevice.h>
#include <linux/kernel.h>
#include <linux/major.h>
#include <linux/mutex.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/stat.h>
#include <linux/init.h>
#include <linux/device.h>
#include <linux/tty.h>
#include <linux/kmod.h>
#include <linux/gfp.h>
#include <linux/gpio/consumer.h>
#include <linux/platform_device.h>

static int major = 0;
static struct class *gpioctr_class;
static struct gpio_desc *gpioctr_gpio;

static ssize_t gpio_drv_read(struct file *file, char __user *buf,
                              size_t size, loff_t *offset)
{
    printk("%s %s line %d\n", __FILE__, __FUNCTION__, __LINE__);
    return 0;
}

static ssize_t gpio_drv_write(struct file *file, const char __user *buf,
                               size_t size, loff_t *offset)
{
    int err;
    char status;
    printk("%s %s line %d\n", __FILE__, __FUNCTION__, __LINE__);
    err = copy_from_user(&status, buf, 1);
    gpiod_set_value(gpioctr_gpio, status);
    return 1;
}

static int gpio_drv_open(struct inode *node, struct file *file)
{
    gpiod_direction_output(gpioctr_gpio, 0);
    return 0;
}

static int gpio_drv_close(struct inode *node, struct file *file)
{
    printk("%s %s line %d\n", __FILE__, __FUNCTION__, __LINE__);
    return 0;
}

static struct file_operations gpioctr_drv = {
    .owner   = THIS_MODULE,
    .open    = gpio_drv_open,
    .read    = gpio_drv_read,
    .write   = gpio_drv_write,
    .release = gpio_drv_close,
};

static int chip_demo_gpio_probe(struct platform_device *pdev)
{
    /* Defined in device tree: gpioctr-gpios=<...>; */
    gpioctr_gpio = gpiod_get(&pdev->dev, "gpioctr", 0);
    if (IS_ERR(gpioctr_gpio)) {
        dev_err(&pdev->dev, "Failed to get GPIO for led\n");
        return PTR_ERR(gpioctr_gpio);
    }

    major = register_chrdev(0, "myir_gpioctr", &gpioctr_drv);
    gpioctr_class = class_create(THIS_MODULE, "myir_gpioctr_class");
    if (IS_ERR(gpioctr_class)) {
        printk("%s %s line %d\n", __FILE__, __FUNCTION__, __LINE__);
        unregister_chrdev(major, "gpioctr");
        gpiod_put(gpioctr_gpio);
        return PTR_ERR(gpioctr_class);
    }

    device_create(gpioctr_class, NULL, MKDEV(major, 0), NULL, "myir_gpioctr%d", 0);
    return 0;
}

static int chip_demo_gpio_remove(struct platform_device *pdev)
{
    device_destroy(gpioctr_class, MKDEV(major, 0));
    class_destroy(gpioctr_class);
    unregister_chrdev(major, "myir_gpioctr");
    gpiod_put(gpioctr_gpio);
    return 0;
}

static const struct of_device_id myir_gpioctr[] = {
    { .compatible = "myir,gpioctr" },
    { },
};

static struct platform_driver chip_demo_gpio_driver = {
    .probe  = chip_demo_gpio_probe,
    .remove = chip_demo_gpio_remove,
    .driver = {
        .name          = "myir_gpioctr",
        .of_match_table = myir_gpioctr,
    },
};

static int __init gpio_init(void)
{
    return platform_driver_register(&chip_demo_gpio_driver);
}

static void __exit gpio_exit(void)
{
    platform_driver_unregister(&chip_demo_gpio_driver);
}

module_init(gpio_init);
module_exit(gpio_exit);
MODULE_LICENSE("GPL");
```

#### 2) Compile Driver Directly into the Kernel

Create `gpioctr.c` in `drivers/char/` of the kernel source code, then modify the following files:

**Kconfig** (`drivers/char/Kconfig`):
```kconfig
config SAMPLE_GPIO
    tristate "this is a gpio test driver"
    depends on CONFIG_GPIOLIB
```

**Makefile** (`drivers/char/Makefile`):
```makefile
obj-$(CONFIG_SAMPLE_GPIO) += gpioctr.o
```

**defconfig** (`linux/arch/arm/configs/myd_y6ulx_defconfig`):
```
CONFIG_SAMPLE_GPIO=y
```

Then compile and update the kernel according to Section 5.4.

#### 3) Compile Driver Outside the Kernel Source Tree

Add `gpioctr.c` to your working directory and create a standalone `Makefile`:

```makefile
# Modify KERN_DIR to point to your kernel source directory
KERN_DIR = /home/myir/myir-imx-linux/

obj-m += gpioctr.o

all:
	make -C $(KERN_DIR) M=`pwd` modules

clean:
	make -C $(KERN_DIR) M=`pwd` modules clean
	rm -rf modules.order

# To compile a.c and b.c into ab.ko:
# ab-y := a.o b.o
# obj-m += ab.o
```

Set up the toolchain environment and build:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
myir$ make
```

Expected output:

```
make -C /home/myir/myir-imx-linux/ M=`pwd` modules
CC [M]  /home/myir/demo_gpioctr/gpioctr.o
Building modules, stage 2.
MODPOST 1 modules
CC [M]  /home/myir/demo_gpioctr/gpioctr.mod.o
LD [M]  /home/myir/demo_gpioctr/gpioctr.ko
```

Copy `gpioctr.ko` to the `/lib/modules/` directory on the development board, then load with `insmod`.

---

### 6.3.3 How to Control a GPIO in Userspace

Linux provides three methods to control a GPIO in userspace:

- Shell command
- System call
- Library function (libgpiod)

#### 1) Shell Command

Shell control of pins is implemented via the file operation interface provided by Linux. For detailed steps, refer to *MYD-Y6ULX Linux Software Evaluation Guide*, Section 3.1.

#### 2) GPIO Control Through libgpiod

From Linux kernel version 4.8, a new GPIO character device mode was introduced. Each GPIO group has a corresponding device node under `/dev/` (e.g. `/dev/gpiochip0` for GPIO0, `/dev/gpiochip1` for GPIO1, etc.).

`libgpiod` provides a C library and tools for interacting with these GPIO character devices. Source code: [https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/)

The following example toggles **GPIO1_24 (J14-PIN5)**:

```c
// example-gpio.c
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <linux/gpio.h>

int main(int argc, char **argv)
{
    struct gpiohandle_request req;
    struct gpiohandle_data data;
    char chrdev_name[20];
    int fd, ret;

    strcpy(chrdev_name, "/dev/gpiochip0");

    /* Open device: gpiochip0 for GPIO1 */
    fd = open(chrdev_name, 0);
    if (fd == -1) {
        ret = -errno;
        fprintf(stderr, "Failed to open %s\n", chrdev_name);
        return ret;
    }

    /* Request GPIO line: GPIO1_24 */
    req.lineoffsets[0] = 24;
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    memcpy(req.default_values, &data, sizeof(req.default_values));
    strcpy(req.consumer_label, "gpio1_24");
    req.lines = 1;

    ret = ioctl(fd, GPIO_GET_LINEHANDLE_IOCTL, &req);
    if (ret == -1) {
        ret = -errno;
        fprintf(stderr, "Failed to issue GET LINEHANDLE IOCTL (%d)\n", ret);
    }

    if (close(fd) == -1)
        perror("Failed to close GPIO character device file");

    /* Toggle GPIO in loop */
    while (1) {
        data.values[0] = !data.values[0];
        ret = ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
        if (ret == -1) {
            ret = -errno;
            fprintf(stderr, "Failed to issue ioctl (%d)\n", ret);
        }
        sleep(1);
    }

    /* Release line */
    ret = close(req.fd);
    if (ret == -1) {
        perror("Failed to close GPIO LINEHANDLE device file");
        ret = -errno;
    }

    return ret;
}
```

Build and run:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
myir$ $CC example-gpio.c -o example-gpio
# Copy to board, then run:
root@myd-y6ull14x14:~# example-gpio
```

#### 3) System Call to Control GPIO

Using the kernel driver from Section 6.3.2, the following application controls the pin via system calls:

```c
// gpiotest.c
// Usage:
//   ./gpiotest /dev/myir_gpioctr0 on
//   ./gpiotest /dev/myir_gpioctr0 off

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    int fd;
    char status;

    if (argc != 3) {
        printf("Usage: %s <dev> <on | off>\n", argv[0]);
        return -1;
    }

    fd = open(argv[1], O_RDWR);
    if (fd == -1) {
        printf("can not open file %s\n", argv[1]);
        return -1;
    }

    if (0 == strcmp(argv[2], "on")) {
        status = 1;
        write(fd, &status, 1);
    } else {
        status = 0;
        write(fd, &status, 1);
    }

    close(fd);
    return 0;
}
```

Build and run:

```bash
myir$ source /opt/test5.10/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
myir$ $CC gpiotest.c -o gpiotest
# Copy to board /usr/bin/, then run:
root@myir:~# gpiotest /dev/myir_gpioctr0 on    # Set pin HIGH
root@myir:~# gpiotest /dev/myir_gpioctr0 off   # Set pin LOW
```