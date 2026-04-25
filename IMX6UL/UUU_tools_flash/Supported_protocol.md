# 5. Supported Protocols

UUU is a scripted, multi-protocol system.

## Built-in Config Table

| Protocol | Chip | VID | PID | BcdVersion |
|---|---|---|---|---|
| SDPS | MX8QXP | 0x1fc9 | 0x012f | [0x0002..0xffff] |
| SDPS | MX8QM | 0x1fc9 | 0x0129 | [0x0002..0xffff] |
| SDP | MX7D | 0x15a2 | 0x0076 | |
| SDP | MX6Q | 0x15a2 | 0x0054 | |
| SDP | MX6D | 0x15a2 | 0x0061 | |
| SDP | MX6SL | 0x15a2 | 0x0063 | |
| SDP | MX6SX | 0x15a2 | 0x0071 | |
| SDP | MX6UL | 0x15a2 | 0x007d | |
| SDP | MX6ULL | 0x15a2 | 0x0080 | |
| SDP | MX6SLL | 0x1fc9 | 0x0128 | |
| SDP | MX7ULP | 0x1fc9 | 0x0126 | |
| SDP | MXRT106X | 0x1fc9 | 0x0135 | |
| SDP | MX8MM | 0x1fc9 | 0x0134 | |
| SDP | MX8MQ | 0x1fc9 | 0x012b | |
| SDPU | SPL | 0x0525 | 0xb4a4 | [0x0000..0x04ff] |
| SDPV | SPL1 | 0x0525 | 0xb4a4 | [0x0500..0xffff] |
| FBK | — | 0x066f | 0x9afe | |
| FBK | — | 0x066f | 0x9bff | |
| FB | — | 0x0525 | 0xa4a5 | |
| FB | — | 0x18d1 | 0x0d02 | |

## Protocol to USB Low-Level Map

| UUU Protocol | USB Low Level | Target |
|---|---|---|
| SDP | HID | i.MX6/7, i.MX8MM, i.MX8MQ |
| SDPU / SDPV | HID | Uboot implementation of SDP; SPL downloads uboot |
| SDPS | HID | i.MX8QXP, i.MX8QM |
| FB | WinUSB (Windows), raw transfer via libusb | |
| FBK | WinUSB (Windows), raw transfer via libusb | |

---

## 5.1 SDP — i.MX6/7 ROM Download Protocol

### 5.1.1 Supported Commands

**Run DCD from image with IVT header:**
```
dcd -f <filename>
```

**Write image to address:**
```
write -f <filename> [-addr 0x000000] [-ivt 0]
```
> `ivt 0` means write to the address which the IVT pointer points to.

**Jump to image with IVT header:**
```
jump -f <filename> [-ivt 0]
```

**Boot image** (includes DCD, write, and jump):
```
boot -f <filename> [-nojump]
```

---

## 5.2 HABv4 Closed Chip Support

- For boot images **without** a DCD table: the same image used for SD card / eMMC boot can be used directly with UUU.
- For boot images **with** a DCD table: the DCD is loaded in OCRAM and must be properly signed.

Since U-Boot v2017.01, a build log containing U-Boot and DCD addresses is available after building:

```bash
$ cat u-boot-dtb.imx.log
Image Type:   Freescale IMX Boot Image
Image Ver:    2 (i.MX53/6/7 compatible)
Mode:         DCD
Data Size:    602112 Bytes = 588.00 KiB = 0.57 MiB
Load Address: 877ff420
Entry Point:  87800000
HAB Blocks:   877ff400 00000000 0008ec00
DCD Blocks:   00910000 0000002c 000001c4
```

Use the above to create the CSF Authenticate Data command:

```
Block = 0x877ff400 0x00000000 0x0006DC00 "u-boot-dtb.imx", \
        0x00910000 0x0000002c 0x000001c4 "u-boot-dtb.imx"
```

Alternatively, extract the DCD length directly from the DCD table header:

```bash
$ od -x -j 0x2c -N 4 --endian=big u-boot-dtb.imx
0000054 d201 c440
# DCD Header: 0xd2, DCD Length: 0x01c4, DCD Version: 0x40
```

> For i.MX devices **not** supporting the skip DCD command (i.MX6Dual/Quad and i.MX6SoloLite), the DCD table pointer is cleared in the IVT to prevent the HAB library from reprocessing it during authentication.

Since the IVT is modified during download, **the binary must be signed with a cleared DCD pointer** — but provided with a valid DCD pointer so UUU can locate the DCD table.

Use the following script to handle the DCD pointer:

```bash
#!/bin/bash
# DCD address must be cleared for signature, as UUU will clear it.
if [ "$1" == "clear_dcd_addr" ]; then
    dd if=$2 of=dcd_addr.bin bs=1 count=4 skip=12
    dd if=/dev/zero of=zero.bin bs=1 count=4
    dd if=zero.bin of=$2 seek=12 bs=1 conv=notrunc
fi

# DCD address must be set for mfgtool to localize the DCD table.
if [ "$1" == "set_dcd_addr" ]; then
    dd if=dcd_addr.bin of=$2 seek=12 bs=1 conv=notrunc
    rm zero.bin
fi
```

**Example steps:**
```bash
$ ./mod_4_mfgtool.sh clear_dcd_addr u-boot-dtb.imx
$ ./cst --i u-boot-csf.txt --o u-boot-csf.bin
$ ./mod_4_mfgtool.sh set_dcd_addr u-boot-dtb.imx
```

---

## 5.3 SDPU / SDPV — Uboot Simplified ROM SDP Protocol

Uboot implements the i.MX6/7 ROM SDP protocol. Supported commands are the same as SDP.

**SDPV** is an upgraded version of SDPU that supports the `-skipspl` option for the `write` command.

See [uboot config requirements](#) for more details.

---

## 5.4 SDPS — i.MX8QXP and i.MX8QM ROM Download Protocol

Send image using the SDP command:

```
boot -f <filename> [-offset 0x0000]
```

---

## 5.5 FB — Android Fastboot Protocol

See the [fastboot protocol documentation](#) and [uboot requirements](#) for details.

### 5.5.1 Supported Commands

```
getvar
ucmd <any uboot command>
acmd <any never-returned uboot command, e.g. booti, reboot>
flash [-raw2sparse] <partition> <filename>
download -f <filename>
```

> **Note:** `partition "all"` means the whole device.

Some uboot commands take a long time. The default FB timeout is **2 seconds**. To change it:

```bash
# Set timeout to 10000ms
FB[-t 10000]: ucmd <any uboot command>
```

### Fastboot Environment Variables

| Variable | Description |
|---|---|
| `fastboot_dev` | Fastboot flash device; supports `mmc` and `sata` |
| `fastboot_buffer` | Fastboot download buffer address |
| `fastboot_bytes` | Fastboot download file size |
| `emmc_dev` | eMMC device number |
| `sd_dev` | SD slot device number |

---

## 5.6 FBK — Android Fastboot Protocol (initramfs)

Implemented at initramfs level. See project **imx-uuu**.

### 5.6.1 Supported Commands

| Command | Description |
|---|---|
| `ucmd <cmd>` | Run kernel command and **wait** for it to finish |
| `acmd <cmd>` | Run kernel command and **don't wait** |
| `sync` | Wait for all `acmd` processes to finish |
| `ucp <src> <dst>` | Copy file to/from target board |

**`ucp` conventions:**
- `T:<filename>` — file on the target board
- `T:-` — copy data to target's stdio pipe

**Examples:**
```bash
ucp image T:/root/image       # download image to /root/image on target
ucp T:/root/image image       # upload /root/image from target to local file
```

**Transfer a large file via stdio pipe:**
```bash
acmd tar -                    # run tar in background, read from stdio
ucp rootfs.tar.gz T:-         # send to target stdio pipe
sync                          # wait for tar to exit
```

**Linux environment note:** Each command runs in a separate process, so environment variables do not carry over. Use this workaround:

```bash
FBK: ucmd source /tmp/mtd.sh; flash_erase /dev/mtd${nandrootfs} 0 0
```

---

## 5.7 Common Commands (All Protocols)

| Command | Description |
|---|---|
| `done` | Last command — finishes the whole flow |
| `delay <ms>` | Busy wait for milliseconds |
| `sh` / `shell` | Run an external shell command |
| `< <cmd>` | Use stdout of a shell command as a UUU command (e.g. for burning serial numbers) |

**Example:**
```bash
< echo ucmd print
```

---

# 6. Migration from MFGTool ucl2.xml

In most cases, the uboot fastboot protocol can handle image programming. If you need to load a kernel to burn a full image, use the mapping below.

| ucl2.xml | UUU script |
|---|---|
| `<CMD ... ifdev="MX8QXPB0"> Loading boot image</CMD>` | `SDPS: boot -f flash.bin` |
| `<CMD ... ifdev="MX8MM"> Loading U-boot</CMD>` | `SDP: boot -f flash.bin` + `SDPU: write -f flash.bin -offset 0x57c00` + `SDPU: jump` |
| Load `Image` to `0x80280000` | `FB: ucmd download -f Image` |
| Load `initramfs.cpio.gz.uboot` to `0x83800000` | `FB: ucmd download -f initramfs.cpio.gz.uboot` |
| Load `fsl-imx8qxp.dtb` to `0x83000000` | `FB: ucmd download -f fsl-imx8qxp.dtb` |
| `<CMD type="push" body="send" file="mksdcard.sh.tar">` | `FBK: ucp mksdcard.sh.tar t:/tmp` |
| `tar xf $FILE` | `FBK: ucmd tar xf /tmp/mksdcard.sh.tar -d /tmp` |
| `sh mksdcard.sh /dev/mmcblk%mmc%` | `FBK: ucmd mksdcard.sh /dev/mmcblk0mmc` |
| Send `imx-boot-imx8qxp-sd.bin` | `FBK: ucp imx-boot-imx8qxp-sd.bin t:/tmp` |
| `dd if=/dev/zero ... seek=4096` (clear u-boot arg) | `FBK: ucmd dd if=/dev/zero of=/dev/mmcblk0 bs=1k seek=4096 conv=fsync count=8` |
| `dd if=$FILE of=/dev/mmcblk0 bs=1k seek=33` | `FBK: ucmd dd if=/tmp/imx-boot-imx8qxp-sd.bin of=/dev/mmcblk0 bs=1k seek=33 conv=fsync` |
| Wait for partition ready | `FBK: ucmd while [ ! -e /dev/mmcblk0p1 ]; do sleep 1; echo waiting...; done` |
| `mkfs.vfat /dev/mmcblk0p1` | `FBK: ucmd mkfs.vfat /dev/mmcblk0p1` |
| `mkdir -p /mnt/mmcblk0p1` | `FBK: ucmd mkdir -p /mnt/mmcblk0p1` |
| `mount -t vfat /dev/mmcblk0p1 /mnt/mmcblk0p1` | `FBK: ucmd vfat /dev/mmcblk0p1 /mnt/mmcblk0p1` |
| Send `Image` (kernel) | `FBK: ucp Image t:/tmp` |
| `cp $FILE /mnt/mmcblk0p1/Image` | `FBK: ucmd /tmp/Image /mnt/mmcblk0p1/Image` |
| Send `fsl-imx8qxp.dtb` | `FBK: ucp fsl-imx8qxp.dtb /tmp` |
| `cp $FILE /mnt/mmcblk0p1/fsl-imx8qm.dtb` | `FBK: ucmd cp /tmp/fsl-imx8qxp.dtb /mnt/mmcblk0p1/` |
| `umount /mnt/mmcblk0p1` | `FBK: ucmd umount /mnt/mmcblk0p1` |
| `mkfs.ext3 -F -j /dev/mmcblk0p2` | `FBK: ucmd mkfs.ext3 -F -j /dev/mmcblk0p2` |
| `mkdir -p /mnt/mmcblk0p2` | `FBK: ucmd mkdir -p /mnt/mmcblk0p2` |
| `mount -t ext3 /dev/mmcblk0p2 /mnt/mmcblk0p2` | `FBK: ucmd mount -t ext3 /dev/mmcblk0p2 /mnt/mmcblk0p2` |
| `pipe tar -jxv -C /mnt/mmcblk0p2` (send rootfs) | `FBK: acmd tar -jxv -C /mnt/mmcblk0p2` + `FBK: ucp rootfs.tar.bz2 t:-` |
| Finish rootfs write (`frf`) | `FBK: sync` |
| `umount /mnt/mmcblk0p2` | `FBK: ucmd umount /mnt/mmcblk0p2` |
| `echo Update Complete!` | `done` |