# 3. Usage Examples

---

## 3.1 Basic

### 3.1.1 Download Bootloader for iMX6 / iMX7

```bash
uuu uboot.imx
```

### 3.1.2 Download Bootloader for iMX8QXP

```bash
uuu flash.bin
```

### 3.1.3 Download SPL and Uboot (e.g. iMX8MQ)

```bash
uuu sdp:  boot -f flash.bin
uuu sdpu: delay 1000
uuu sdpu: write -f flash.bin -offset 0x57c00
uuu sdpu: jump
```

### 3.1.4 Burn Android Image to eMMC

```bash
uuu android.zip
```

> ⚠️ Not implemented by default yet.

### 3.1.5 Burn Yocto Image to eMMC

```bash
uuu L4.9.123_2.3.0_8mm-ga.zip
```

---

## 3.2 Built-in Scripts

| Command | Description |
|---|---|
| `uuu -b emmc bootloader` | Write bootloader to eMMC |
| `uuu -b emmc_all bootloader rootfs.sdcard` | Write rootfs to eMMC |
| `uuu -b emmc_all bootloader rootfs.sdcard.bz2/*` | Decompress rootfs and write to eMMC |
| `uuu -b sd bootloader` | Write bootloader to SD card |
| `uuu -b sd_all bootloader rootfs.sdcard` | Write rootfs to SD card |
| `uuu -b sd_all bootloader rootfs.sdcard.bz2/*` | Decompress rootfs and write to SD card |
| `uuu -b qspi qspi_bootloader` | Write bootloader to QSPI |
| `uuu -b qspi qspi_bootloader m4image` | Write m4image to QSPI |
| `uuu -b spl bootloader` | Download SPL and uboot |

> **Notes:**
> - Some boards have multiple SD slots. Built-in scripts only work when the uboot environment variable `${sd_dev}` points to the correct slot.
> - Some boards do not have an eMMC chip — the `emmc` built-in script does not work on such boards.

---

## 3.3 Multi-Board Support

### 3.3.1 Same Boards

Run daemon mode for multiple identical boards connected simultaneously:

```bash
uuu -d uuu.auto
```

### 3.3.2 Different Boards

Run separate UUU instances, each monitoring specific USB ports:

```bash
# Monitor ports 1:1 and 2:1 for Board A
uuu -d -m 1:1 -m 2:1 boardA_uuu.auto

# Monitor ports 1:3 and 4:1 for Board B
uuu -d -m 1:3 -m 4:1 boardB_uuu.auto
```

> ⚠️ **Warning:** Avoid monitoring the same port with different UUU instances — this causes unexpected results.

---

## 3.4 Talk with Fastboot

### 3.4.1 Boot Linux Kernel

```bash
uuu FB: ucmd setenv fastboot_buffer ${loadaddr}
uuu FB: download -f Image
uuu FB: ucmd setenv fastboot_buffer ${fdt_addr}
uuu FB: download -f imx8qxp_mek.dtb
uuu FB: acmd booti ${loadaddr} - ${fdt_addr}
```

**Extended Fastboot Environment Variables:**

| Variable | Description |
|---|---|
| `fastboot_buffer` | Image download address |
| `fastboot_bytes` | Byte size of the previously downloaded image |

### 3.4.2 Write Image to eMMC

```bash
uuu FB: flash -raw2sparse all
```