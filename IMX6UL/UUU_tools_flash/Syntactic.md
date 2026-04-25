# 2. Syntactic

```
uuu (Universal Update Utility) for nxp imx chips -- libuuu_1.1.87-7-gad2ec1f
```

---

## 2.1 Command Line Usage

```
uuu [-d -m -v -V] bootloader       download bootloader to board by usb
uuu [-d -m -v -V] cmdlist          run all commands in cmdlist file
                                   If it is a path, search uuu.auto in dir
                                   If it is a zip, search uuu.auto in zip
uuu [-d -m -v -V] cmd              Run one command, use -H to see detail
```

**Options:**

| Option | Description |
|---|---|
| `-d` | Daemon mode — wait forever |
| `-v` / `-V` | Verbose mode; `-V` enables libusb error/warning info |
| `-m USBPATH` | Only monitor specified paths, e.g. `-m 1:2` or `-m 1:3` |
| `-s` | Enter shell mode |
| `-h` / `-H` | Show help; `-H` means detailed help |

**Example:**
```bash
SDPS: boot -f flash.bin
```

> **Shell mode note:** `uuu.inputlog` records all input commands. You can rerun them with:
> ```bash
> uuu uuu.inputlog
> ```

---

## 2.2 Built-in Scripts

```
uuu [-d -m -v] -b[run] arg...     Run built-in scripts
uuu -bshow                         Show built-in scripts
```

| Script | Description | Arguments |
|---|---|---|
| `emmc` | Burn bootloader to eMMC boot partition | `arg0: flash.bin` |
| `emmc_all` | Burn whole image to eMMC | `arg0: flash.bin` `arg1: rootfs.sdcard` |
| `qspi` | Burn bootloader to QSPI NOR flash | `arg0: flexspi.bin` |
| `bootloader` | Burn image to FlexSPI | `arg0: flexspi.bin` `arg1: image [Optional]` — default same as bootloader |
| `sd` | Burn bootloader to SD card | `arg0: flash.bin` |
| `sd_all` | Burn whole image to SD card | `arg0: flash.bin` `arg1: rootfs.sdcard` |
| `spl` | Boot SPL and uboot | `arg0: flash.bin` |

---

## 2.3 Command Format

```
PROTOCOL: COMMAND ARG
```

### Common Commands (all protocols)

| Command | Description |
|---|---|
| `done` | Last command for the whole flow |
| `delay <ms>` | Delay in milliseconds |
| `sh` / `shell` | Run a shell command (e.g. `wget` to fetch file from network) |
| `<` | Use shell command's output as a UUU command |

> **Note on `<` command:** Generally used to burn sequence numbers such as production ID or MAC address.
> ```
> FB:< echo ucmd print
> ```

---

## 2.4 Protocols

### CFG — Configure Protocol

Configure USB device parameters for a specific protocol:

```
CFG: SDP|SDPS|FB|Fastboot|FBK -chip -pid -vid [-bcdversion]
```

---

### SDPS — Stream Download Protocol (MX8QXPB0+)

```
SDPS: boot -f <file> [-offset 0x0000]
```

---

### SDP — Serial Download Protocol (iMX6 / iMX7)

HID download protocol commands:

```
SDP: dcd -f <file>
SDP: write -f <file> [-addr 0x000000] [-ivt 0]
SDP: jump -f <file> [-ivt 0]
SDP: boot -f <file> [-nojump]
```

---

### FB / Fastboot — Android Fastboot Protocol

```
FB[-t <timeout>]: getvar
FB[-t <timeout>]: ucmd
FB[-t <timeout>]: acmd
FB[-t <timeout>]: flash [-raw2sparse]
FB[-t <timeout>]: download -f <file>
```

> Timeout unit is **milliseconds (ms)**.

---

### FBK — Fastboot Kernel Protocol

Communicates with kernel using fastboot protocol. **NOT compatible with standard fastboot tools.**

| Command | Description |
|---|---|
| `ucmd` | Run command and **wait** for it to finish |
| `acmd` | Run command and **don't wait** |
| `sync` | Wait for all `acmd` processes to finish |
| `ucp` | Copy file to/from target board |

**`ucp` syntax:**

```
ucp <src> <dst>
```

- `T:` prefix means target board file
- `T:-` means copy data to target's stdio pipe

**Examples:**
```bash
ucp image T:/root/image    # download image to /root/image on target
ucp T:/root/image image    # upload /root/image from target to local file
```

**Example — transfer a large file via stdio pipe:**
```bash
acmd tar -               # run tar in background, read data from stdio
ucp rootfs.tar.gz T:-    # send to target stdio pipe
sync                     # wait for tar process to exit
```

---

## 2.5 Full Examples

```bash
SDPS: boot -f flash.bin
SDP: boot -f flash.bin

# Configure custom VID/PID
CFG: SDP: -chip imx6ull -pid 0x1234 -vid 0x5678

# Boot without jumping
SDP: boot -f u-boot-imx7dsabresd_sd.imx -nojump

# Write kernel, dtb, and initramfs to DDR then jump
SDP: write -f zImage -addr 0x80800000
SDP: write -f zImage-imx7d-sdb.dtb -addr 0x83000000
SDP: write -f fsl-image-mfgtool-initramfs-imx_mfgtools.cpio.gz.u-boot -addr 0x83800000
SDP: jump -f u-boot-dtb.imx -ivt 0
```