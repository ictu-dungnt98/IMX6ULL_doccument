# Hướng dẫn Custom U-Boot Yocto cho Forlinx OKMX6ULL-S
> **Board:** Forlinx OKMX6ULL-S | **SoC:** NXP i.MX6ULL | **RAM:** DDR3 512MB | **Storage:** eMMC  
> **Yocto:** Kirkstone (5.15) | **Base BSP:** NXP i.MX Yocto (`imx-yocto`)  
> **Distro:** `fsl-imx-fb` | **Base machine:** `imx6ull14x14evk`

---

## Bối cảnh vấn đề

BSP gốc của Forlinx đã **chết** (không còn maintained), không build được U-Boot từ source Forlinx. Giải pháp:

- Dùng **NXP i.MX Yocto BSP chính thức** (`imx-yocto`) làm nền
- Build thành công cho board NXP EVK (`imx6ull14x14evk`) làm base
- Tạo custom layer `meta-okmx6ull` với DDR config **extract trực tiếp từ binary gốc Forlinx**
- Override machine config để phù hợp với hardware Forlinx

---

## Phân tích hardware từ binary Forlinx

Trước khi build, parse DCD table trong file `u-boot-emmc.imx` gốc của Forlinx để lấy chính xác các thông số hardware:

| Thông số | Giá trị | Nguồn |
|----------|---------|-------|
| DDR Type | DDR3 | MDMISC=0x00211740 |
| Bus Width | 16-bit | MDCTL=0x84180000 |
| Density | 512MB (0x20000000) @ 0x80000000 | MDASP + memory node DTB |
| Row / Col | 15 Row / 10 Col | MDCTL decode |
| Chip Select | 1 CS (CS0 only) | MDCTL bit31 |
| U-Boot Entry | 0x87800000 | IVT header |
| UART Console | UART1 / ttymxc0 | DTB stdout-path |
| eMMC | uSDHC2 (`0x02194000`), 8-bit bus | DTB + pinmux |
| SD Card | uSDHC1 (`0x02190000`), 4-bit bus | DTB |

### MMDC Registers (DDR3 Init — Extract từ DCD)

| Register | Address | Value |
|----------|---------|-------|
| MDCTL | 0x021B0000 | 0x84180000 |
| MDPDC | 0x021B0004 | 0x0002002D |
| MDCFG0 | 0x021B0008 | 0x1B333030 |
| MDCFG1 | 0x021B000C | 0x676B52F3 |
| MDCFG2 | 0x021B0010 | 0xB66D0B63 |
| MDMISC | 0x021B0018 | 0x00211740 |
| MDREF | 0x021B0020 | 0x00000800 |
| MDRWD | 0x021B002C | 0x000026D2 |
| MDOR | 0x021B0030 | 0x006B1023 |
| MDASP | 0x021B0404 | 0x00011006 |
| MPZQHWCTRL | 0x021B0800 | 0xA1390003 |
| MPDGCTRL0 | 0x021B08B8 | 0x00000800 |
| MPRDDLCTL | 0x021B0848 | 0x40403034 |
| MPWRDLCTL | 0x021B0850 | 0x40403A34 |
| MPWLDECTRL0 | 0x021B0890 | 0x00400000 |

---

## Cấu trúc Yocto BSP ban đầu

```
~/imx-yocto-new/
├── build-fb/
│   └── conf/
│       ├── bblayers.conf      ← danh sách layers
│       └── local.conf         ← MACHINE, DISTRO config
├── downloads/
└── sources/
    ├── poky/
    ├── meta-freescale/
    ├── meta-freescale-3rdparty/
    ├── meta-freescale-distro/
    ├── meta-imx/
    │   ├── meta-bsp/          ← chứa imx6ull14x14evk.conf
    │   ├── meta-sdk/
    │   ├── meta-ml/
    │   └── meta-v2x/
    ├── meta-openembedded/
    ├── meta-qt6/
    ├── meta-virtualization/
    └── meta-okmx6ull/         ← layer tao tạo mới
```

---

## Các bước thực hiện

---

### Bước 1: Tạo custom layer `meta-okmx6ull`

```bash
cd ~/imx-yocto-new/sources
mkdir -p meta-okmx6ull/conf/machine
mkdir -p meta-okmx6ull/recipes-bsp/u-boot/files
```

---

### Bước 2: Tạo `layer.conf`

```bash
cat > ~/imx-yocto-new/sources/meta-okmx6ull/conf/layer.conf << 'EOF'
BBPATH .= ":${LAYERDIR}"
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"
BBFILE_COLLECTIONS += "meta-okmx6ull"
BBFILE_PATTERN_meta-okmx6ull = "^${LAYERDIR}/"
BBFILE_PRIORITY_meta-okmx6ull = "10"
LAYERDEPENDS_meta-okmx6ull = "core"
LAYERSERIES_COMPAT_meta-okmx6ull = "kirkstone"
EOF
```

**Giải thích:**
- `LAYERDEPENDS = "core"` — chỉ depend `core`, không khai báo `meta-freescale` vì nó đã có trong `bblayers.conf` rồi. Nếu khai báo thêm sẽ bị lỗi `Layer depends on layer X but not enabled`
- `BBFILE_PRIORITY = "10"` — priority cao hơn các layer base (thường là 6) để override được các recipe/config của NXP

---

### Bước 3: Tạo machine config

```bash
cat > ~/imx-yocto-new/sources/meta-okmx6ull/conf/machine/okmx6ull-s-emmc.conf << 'EOF'
#@TYPE: Machine
#@NAME: Forlinx OKMX6ULL-S eMMC
#@DESCRIPTION: Forlinx SOM OKMX6ULL-S, i.MX6ULL, DDR3 512MB, eMMC

MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"

include conf/machine/include/imx-base.inc
include conf/machine/include/arm/armv7a/tune-cortexa7.inc

KERNEL_DEVICETREE = "imx6ull-14x14-evk-emmc.dtb"

# Chỉ enable emmc config
# Dùng ?= để tránh conflict với UBOOT_MACHINE
UBOOT_CONFIG ?= "emmc"
UBOOT_CONFIG[emmc] = "mx6ull_14x14_evk_emmc_config,sdcard"

MACHINE_FEATURES += "optee"
OPTEE_BIN_EXT = "6ullevk"

SERIAL_CONSOLES = "115200;ttymxc0"
EOF
```

**Giải thích:**
- **Không dùng `require imx6ull14x14evk.conf`** vì base conf đó set `UBOOT_CONFIG ??=` và `UBOOT_MACHINE` cùng lúc gây conflict lỗi `You cannot use UBOOT_MACHINE and UBOOT_CONFIG at the same time`
- **Tự include** `imx-base.inc` và `tune-cortexa7.inc` thay thế — đây là 2 file mà `imx6ull14x14evk.conf` cũng include
- `MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"` — khai báo các override prefix để các recipe nhận đúng SoC family, quan trọng để các bbappend của NXP hoạt động đúng
- `UBOOT_CONFIG ?=` (weak assign) — cho phép override từ `local.conf` nếu cần sau này
- DTB dùng `imx6ull-14x14-evk-emmc.dtb` của NXP trước vì hardware rất gần nhau, đủ để boot. DTB riêng cho Forlinx sẽ làm ở bước sau

---

### Bước 4: Tạo U-Boot defconfig

```bash
cat > ~/imx-yocto-new/sources/meta-okmx6ull/recipes-bsp/u-boot/files/okmx6ull_s_emmc_defconfig << 'EOF'
CONFIG_ARM=y
CONFIG_ARCH_MX6=y
CONFIG_SYS_TEXT_BASE=0x87800000
CONFIG_SYS_MALLOC_LEN=0x1000000
CONFIG_ENV_SIZE=0x2000
CONFIG_ENV_OFFSET=0x400000
CONFIG_ENV_SECT_SIZE=0x20000
CONFIG_MX6ULL=y
CONFIG_TARGET_MX6ULL_14X14_EVK=y
CONFIG_DEFAULT_DEVICE_TREE="imx6ull-okmx6ull-s-emmc"
CONFIG_DISTRO_DEFAULTS=y
CONFIG_BOOTDELAY=3
CONFIG_SYS_LOAD_ADDR=0x80800000
CONFIG_CMD_GPIO=y
CONFIG_CMD_I2C=y
CONFIG_CMD_MMC=y
CONFIG_CMD_USB=y
CONFIG_CMD_DHCP=y
CONFIG_CMD_PING=y
CONFIG_CMD_EXT4=y
CONFIG_CMD_FAT=y
CONFIG_ENV_IS_IN_MMC=y
CONFIG_SYS_MMC_ENV_DEV=1
CONFIG_SYS_MMC_ENV_PART=1
CONFIG_MMC=y
CONFIG_FSL_ESDHC_IMX=y
CONFIG_FSL_USDHC=y
CONFIG_PHYLIB=y
CONFIG_FEC_MXC=y
CONFIG_MII=y
CONFIG_OF_CONTROL=y
CONFIG_OF_BOARD_SETUP=y
CONFIG_DM=y
CONFIG_DM_MMC=y
CONFIG_DM_ETH=y
CONFIG_DM_GPIO=y
CONFIG_DM_I2C=y
EOF
```

**Giải thích:**
- `CONFIG_SYS_TEXT_BASE=0x87800000` — load address lấy từ IVT header binary Forlinx gốc, phải khớp chính xác
- `CONFIG_TARGET_MX6ULL_14X14_EVK=y` — dùng board code NXP EVK, tương thích tốt với i.MX6ULL
- `CONFIG_ENV_IS_IN_MMC=y` + `ENV_DEV=1` — lưu U-Boot environment trên eMMC (mmcblk1)
- `CONFIG_SYS_MMC_ENV_PART=1` — lưu env ở boot partition của eMMC

---

### Bước 5: Tạo U-Boot bbappend

```bash
cat > ~/imx-yocto-new/sources/meta-okmx6ull/recipes-bsp/u-boot/u-boot-imx_%.bbappend << 'EOF'
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:okmx6ull-s-emmc = " \
    file://okmx6ull_s_emmc_defconfig \
"

do_configure:append:okmx6ull-s-emmc() {
    cp ${WORKDIR}/okmx6ull_s_emmc_defconfig \
       ${S}/configs/okmx6ull_s_emmc_defconfig
}
EOF
```

**Giải thích:**
- `FILESEXTRAPATHS:prepend` — thêm thư mục `files/` của layer vào search path để Yocto tìm thấy defconfig
- `SRC_URI:append:okmx6ull-s-emmc` — chỉ append khi `MACHINE = "okmx6ull-s-emmc"`, không ảnh hưởng machine khác
- `do_configure:append` — copy defconfig vào source tree sau bước configure để U-Boot build dùng đúng config

---

### Bước 6: Thêm layer vào `bblayers.conf`

```bash
# Xóa dòng lỗi cũ nếu có
sed -i '/meta-okmx6ull/d' ~/imx-yocto-new/build-fb/conf/bblayers.conf

# Thêm đúng cú pháp
echo 'BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"' >> \
    ~/imx-yocto-new/build-fb/conf/bblayers.conf

# Kiểm tra
tail -5 ~/imx-yocto-new/build-fb/conf/bblayers.conf
```

**Lưu ý lỗi đã gặp:** Không dùng `echo '  ${BSPDIR}/... \\'` vì nó append ra ngoài block `BBLAYERS = " "` gây `ParseError: unparsed line`. Phải dùng `BBLAYERS +=` riêng biệt.

---

### Bước 7: Đổi MACHINE trong `local.conf`

```bash
sed -i "s/MACHINE ??= 'imx6ull14x14evk'/MACHINE ??= 'okmx6ull-s-emmc'/" \
    ~/imx-yocto-new/build-fb/conf/local.conf

# Kiểm tra
grep -E 'MACHINE|DISTRO' ~/imx-yocto-new/build-fb/conf/local.conf
```

**Kết quả expected:**
```
MACHINE ??= 'okmx6ull-s-emmc'
DISTRO ?= 'fsl-imx-fb'
```

---

### Bước 8: Build U-Boot

```bash
cd ~/imx-yocto-new
source setup-environment build-fb

# Clean trước khi build (quan trọng sau khi thay đổi config)
bitbake -c cleansstate u-boot-imx

# Build
bitbake u-boot-imx
```

**Kết quả expected:**
```
NOTE: Tasks Summary: Attempted 842 tasks of which 823 didn't need to be rerun and all succeeded.
```

---

### Bước 9: Kiểm tra output và copy

```bash
# Xem các file output
ls ~/imx-yocto-new/build-fb/tmp/deploy/images/okmx6ull-s-emmc/
```

**Output files:**
```
u-boot-okmx6ull-s-emmc.imx        ← FILE CHÍNH dùng để flash
u-boot-emmc-2022.04-r0.imx
u-boot.imx
u-boot.imx-emmc
u-boot-tagged.imx
u-boot-imx-initial-env-*
```

```bash
# Copy sang thư mục flash
cp ~/imx-yocto-new/build-fb/tmp/deploy/images/okmx6ull-s-emmc/u-boot-okmx6ull-s-emmc.imx \
   ~/WORK/UUU_SCRIPT/u-boot-okmx6ull.imx
```

---

## Cấu trúc layer hoàn chỉnh

```
sources/meta-okmx6ull/
├── conf/
│   ├── layer.conf
│   └── machine/
│       └── okmx6ull-s-emmc.conf
└── recipes-bsp/
    └── u-boot/
        ├── u-boot-imx_%.bbappend
        └── files/
            └── okmx6ull_s_emmc_defconfig
```

---

## Các lỗi đã gặp và cách fix

| Lỗi | Nguyên nhân | Fix |
|-----|-------------|-----|
| `ParseError: unparsed line` trong bblayers.conf | Append sai cú pháp, nằm ngoài block `BBLAYERS = " "` | Dùng `BBLAYERS += "..."` thay vì echo vào giữa block |
| `Layer depends on meta-freescale but not enabled` | `LAYERDEPENDS` khai báo layer đã có nhưng Yocto không nhận | Đổi thành `LAYERDEPENDS = "core"` |
| `Nothing PROVIDES u-boot-imx` | `UBOOT_MACHINE` và `UBOOT_CONFIG` conflict khiến recipe bị skip | Bỏ `UBOOT_MACHINE`, chỉ dùng `UBOOT_CONFIG` |
| `You cannot use UBOOT_MACHINE and UBOOT_CONFIG` | Base conf `imx6ull14x14evk.conf` set cả hai khi dùng `require` | Không `require` base conf, tự include `imx-base.inc` trực tiếp |
| `patch does not apply` | Patch skeleton không phải patch thật, hunk không khớp | Bỏ patch, dùng defconfig override thay thế |

---

## Bước tiếp theo

- [ ] Flash `u-boot-okmx6ull.imx` lên board qua `uuu`
- [ ] Verify boot log serial: phải thấy `DRAM: 512 MiB`
- [ ] Tạo DTB riêng cho Forlinx (`imx6ull-okmx6ull-s-emmc.dts`) nếu peripheral không đúng
- [ ] Build full image: `bitbake core-image-minimal`
- [ ] Config kernel cho đúng peripheral Forlinx (Ethernet PHY, CAN, LCD...)