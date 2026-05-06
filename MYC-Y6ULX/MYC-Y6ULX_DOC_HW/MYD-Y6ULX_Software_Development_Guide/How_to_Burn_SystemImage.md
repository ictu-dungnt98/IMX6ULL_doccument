# Chapter 4: Flashing the System Image

The i.MX6UL series products have various startup methods, so different update system tools and methods are needed. Users can choose different ways to update according to their needs. Since the startup mode needs to be adjusted during programming, configure the DIP switch according to the tables below.

---

## 4.1 How to Flash with UUU

> **Note:** The UUU tool is **not compatible with Windows 7**. Please use **Windows 10** or a **Linux** system.

### Tools Requirements

- A development board
- Type-A to Micro-B USB cable
- 12V/2A power adapter

---

### Flashing Steps

The following uses the **MYD-Y6ULY2-V2-4E512D** development board as an example to explain how to flash the `myir-image-full` system image. Other configurations follow the same steps — just replace the script accordingly.

**Step 1:** Set the DIP switch (SW1) — switch the **3rd position to OFF** and the **4th position to ON** (USB Download mode).

**Step 2:** Use a USB cable (Type-A to Micro-B) to connect the **PC USB port** to the development board **Micro USB OTG port (J26)**.

**Step 3:** Use a DC 12V power adapter to connect to the **power socket (J22)** of the development board.

**Step 4:** Open a **cmd window with administrator privileges**, navigate to the `MYD-i.MX6ULX_UUU_v1.1` directory, and run:

```cmd
uuu.exe myd-y6ulx-y2-4e512d-qt.auto
```

**Step 5:** Wait for programming to complete. When finished, the terminal displays **green "Done"** with `Success: 1`.

**Step 6:** Power off, set the DIP switch back to **NAND or eMMC boot mode**, then power on to boot from the board's flash.

---

### Flash Script List

MYD-Y6ULX supports two Flash storage types: **NAND** and **eMMC**. Select the appropriate script when using UUU.

**Table 4-1. MYD-Y6ULX Flash Script List**

| Script Name | Description |
|---|---|
| `myd-y6ulx-y2-4e512d-qt.auto` | Flash full file system — board config **MYD-Y6ULX-Y2-4E512D** |
| `myd-y6ulx-y2-4e512d-core-base.auto` | Flash core file system — board config **MYD-Y6ULX-Y2-4E512D** |
| `myd-y6ulx-y2-256n256d-qt.auto` | Flash full file system — board config **MYD-Y6ULX-Y2-256NAND 256DDR** |
| `myd-y6ulx-y2-256n256d-core-base.auto` | Flash core file system — board config **MYD-Y6ULX-Y2-256NAND 256DDR** |
| `myd-y6ulx-g2-4e512d-qt.auto` | Flash full file system — board config **MYD-Y6ULX-G2-4E512D** |
| `myd-y6ulx-g2-4e512d-core-base.auto` | Flash core file system — board config **MYD-Y6ULX-G2-4E512D** |
| `myd-y6ulx-g2-256n256d-qt.auto` | Flash full file system — board config **MYD-Y6ULX-G2-256NAND 256DDR** |
| `myd-y6ulx-g2-256n256d-core-base.auto` | Flash core file system — board config **MYD-Y6ULX-G2-256NAND 256DDR** |

---

## 4.2 How to Flash with SD Card

For production/mass programming needs, MYiR provides an SD card-based flashing method. The MYD-Y6ULX development board includes a tool for making SD card update system images.

### SD Card Tool Structure

```
MYiR-iMX-mkupdate-sdcard-5.10.9_v1.1/
├── build-sdcard-5.10.9.sh       # Script to create SD card image
├── firmware/                    # Firmware used only for SD card boot (no modification needed)
├── mfgimages-myd-y6uly2/        # Rootfs for Y2 boards -> burned to board flash
│   └── Manifest                 # Defines filenames to be flashed
└── mfgimages-myd-y6ulg2/        # Rootfs for G2 boards -> burned to board flash
```

### Manifest File Example

```bash
hjx@myir-O-E-M:~$ cat mfgimages-myd-y6uly2/Manifest

# i.MX6UL
ubootfile="u-boot.imx"
envfile="boot.scr"
kernelfile="zImage"
dtbfileemmc="myd-y6ull-emmc.dtb"
dtbfilenand="myd-y6ull-gpmi-weim.dtb"
rootfsfile="myir-rootfs.tar.bz2"
ledname="cpu"

# user update
# i.MX6UL-Y2 -- emmc
UBOOT_EMMC256DDR="u-boot-dtb-y2-ddr256-emmc.imx"
UBOOT_EMMC512DDR="u-boot-dtb-y2-ddr512-emmc.imx"
DTBFILE_EMMC="myd-y6ull-emmc.dtb"

# i.MX6UL-Y2 -- nand
UBOOT_NAND256DDR="u-boot-dtb-y2-ddr256-nand.imx"
UBOOT_NAND512DDR="u-boot-dtb-y2-ddr512-nand.imx"
DTBFILE_NAND="myd-y6ull-gpmi-weim.dtb"
KERNELFILE="zImage"
#ROOTFSFILE="rootfs-update.tar.bz2"
```

> **Note:** If you modify the kernel or U-Boot, replace the corresponding file in `mfgimages-myd-y6uly2/` and ensure the filename matches the one defined in the `Manifest`, or replace it directly keeping the original filename.

---

### build-sdcard-5.10.9.sh Script Parameters

| Parameter | Description |
|-----------|-------------|
| `-p` | Platform selection — e.g. `myd-y6uly2` for MYD-Y6ULL (MYC-Y6ULY2) |
| `-n` | On-board memory chip is **NAND** |
| `-e` | On-board memory chip is **eMMC** |
| `-d` | Directory of the update files |
| `-s` | Size of DDR memory (e.g. `256`) |
| `-f` | Rootfs type — supports `qt` or `core` |

---

### Step 1: Make Image File for SD Card

```bash
$ cd MYiR-iMX-mkupdate-sdcard-5.10.9_v1.1

# NAND board, 256MB DDR, Qt rootfs
$ sudo ./build-sdcard-5.10.9.sh -p myd-y6uly2 -n -d mfgimages-myd-y6uly2 -s 256 -f qt

# NAND board, 256MB DDR, Core rootfs
$ sudo ./build-sdcard-5.10.9.sh -p myd-y6uly2 -n -d mfgimages-myd-y6uly2 -s 256 -f core
```

The output is a compressed image file, for example:

```
myd-y6uly2-update-nand-qt-20220817170808.rootfs.sdcard.img.gz
```

---

### Step 2: Write Image to SD Card

#### On Windows

Use the **Win32DiskImager** tool (located in `03_Tools/` directory):

1. Extract and double-click `Win32DiskImager.exe`
2. **Image File (left):** Select the `.img` file to write *(switch file filter to `*.*` if needed)*
3. **Device (right):** Select the drive letter of your SD card
4. Click **Write**

#### On Linux

Use `dmesg | tail` to identify the SD card device name after inserting the card reader (e.g. `/dev/sdb`).

> **Warning:** Do **not** append a partition number — use the base device only (e.g. `/dev/sdb`, not `/dev/sdb1`).

```bash
$ gzip -dc myd-y6uly2-update-nand-qt-20220817170808.rootfs.sdcard.img.gz \
  | sudo dd of=/dev/sdb conv=fsync
```

---

### Step 3: Boot from SD Card and Flash to Board

1. Insert the prepared SD card into card slot **(J8)** of the development board
2. Configure DIP switch **(SW1)** to **SD Card boot mode**
3. Connect USB to TTL serial cable to debug serial port **(JP1)**
4. Connect DC 12V power adapter to power interface **(J22)**
5. Monitor the update progress via serial terminal

The system will boot from the SD card, execute the update script, and write the Linux system image to the NAND/eMMC flash chip.

**LED status indicator (D30):**

| LED State  | Meaning            |
|------------|--------------------|
| Flashing   | Update in progress |
| Always ON  | Update successful  |
| OFF        | Update failed      |

**Step 4:** After update completes, power off and configure the DIP switch back to **NAND or eMMC boot mode**.