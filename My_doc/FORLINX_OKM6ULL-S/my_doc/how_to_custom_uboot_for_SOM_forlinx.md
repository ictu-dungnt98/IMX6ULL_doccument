# Hướng dẫn Custom U-Boot Yocto cho Forlinx OKMX6ULL-S
> **Board:** Forlinx OKMX6ULL-S | **SoC:** NXP i.MX6ULL | **RAM:** DDR3 512MB | **Storage:** eMMC  
> **Yocto:** Kirkstone (5.15) | **Base BSP:** NXP i.MX Yocto (`imx-yocto`)  
> **Distro:** `fsl-imx-fb` | **Base machine:** `imx6ull14x14evk`

---

## Bối cảnh vấn đề

BSP gốc của Forlinx đã **chết** (không còn maintained), không build được U-Boot từ source Forlinx. Giải pháp:

- Dùng **NXP i.MX Yocto BSP chính thức** (`imx-yocto`) làm nền
- Build thành công cho board NXP EVK (`imx6ull14x14evk`) làm base
- Tạo custom layer `meta-okmx6ull` với DDR calibration **extract trực tiếp từ binary gốc Forlinx**
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

---

## Hiệu chỉnh DDR3 (DDR3 Calibration) cho Forlinx OKMX6ULL-S

### Calibration là gì?

DDR3 Configuration gồm 2 phần:

```
┌─────────────────────────────────────────────────────┐
│ TIMING (đặc tính chip DDR3)                         │
│ Phụ thuộc vào chip DDR3, không đổi theo PCB         │
│                                                     │
│  MDCFG0 = 0x1B333030  ← tCL, tRCD, tRP             │
│  MDCFG1 = 0x676B52F3  ← tRAS, tRC, tRFC, tXS       │
│  MDCFG2 = 0xB66D0B63  ← tWR, tRTP, tWTR            │
│                                                     │
│  → NXP EVK và Forlinx GIỐNG NHAU 100%               │
│    vì dùng cùng loại chip DDR3                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ CALIBRATION - Hiệu chỉnh (đặc tính PCB board)      │
│ Phụ thuộc vào độ dài trace, impedance của board     │
│                                                     │
│  MPRDDLCTL = 0x40403034  ← read DQ delay           │
│  MPWRDLCTL = 0x40403A34  ← write DQ delay          │
│  MPDGHWST0 = 0x01480158  ← DQS gating delay        │
│  MPZQSWCTRL= 0x00000001  ← ZQ calibration          │
│  MDMISC    = 0x00211740  ← RALAT=3                 │
│                                                     │
│  → NXP EVK và Forlinx KHÁC NHAU                     │
│    vì PCB layout, độ dài đường mạch khác nhau       │
└─────────────────────────────────────────────────────┘
```

**Nói đơn giản:**
- **Timing** = chip DDR3 cần bao nhiêu clock cycle để đọc/ghi — do nhà sản xuất chip DDR3 quy định, không đổi
- **Calibration (Hiệu chỉnh)** = tín hiệu đi từ SoC → DDR3 mất bao lâu trên PCB — do Forlinx thiết kế board quyết định, mỗi board khác nhau

### So sánh NXP EVK vs Forlinx

| Register | Ý nghĩa | NXP EVK | Forlinx | Khác? |
|----------|---------|---------|---------|-------|
| MDCFG0 | tCL/tRCD/tRP timing | 0x1B333030 | 0x1B333030 | Giống |
| MDCFG1 | tRAS/tRC/tRFC timing | 0x676B52F3 | 0x676B52F3 | Giống |
| MDCFG2 | tWR/tRTP timing | 0xB66D0B63 | 0xB66D0B63 | Giống |
| MDMISC | RALAT (read latency) | 0x00201740 | 0x00211740 | ⚠ Khác |
| MPZQSWCTRL | ZQ calibration | 0x00000004 | 0x00000001 | ⚠ Khác |
| MPDGHWST0 | DQS gating delay | 0x41640158 | 0x01480158 | ⚠ Khác |
| MPRDDLCTL | Read DQ delay | 0x40403237 | 0x40403034 | ⚠ Khác |
| MPWRDLCTL | Write DQ delay | 0x40403C33 | 0x40403A34 | ⚠ Khác |

**Lý do U-Boot NXP EVK (`u-boot-imx6ull14x14evk_sd.imx`) không boot được trên Forlinx:**
```
Calibration NXP sai cho PCB Forlinx
→ DDR init fail hoặc data corrupt → Board treo, không có output serial
```

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

## Các bước thực hiện (đã pass)

---

### Bước 1: Tạo custom layer `meta-okmx6ull`

```bash
cd ~/imx-yocto-new/sources
mkdir -p meta-okmx6ull/conf/machine
mkdir -p meta-okmx6ull/recipes-bsp/u-boot/files
```

---

### Bước 2: Tạo `layer.conf`

> ⚠️ **Lỗi đã gặp:** Ban đầu set `LAYERDEPENDS = "core meta-freescale"` → lỗi `Layer depends on meta-freescale but not enabled`.  
> **Fix:** Đổi thành `LAYERDEPENDS = "core"` — meta-freescale đã có trong bblayers.conf rồi, không cần khai báo thêm.

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
- `LAYERDEPENDS = "core"` — chỉ depend `core`, không khai báo `meta-freescale` vì nó đã có trong `bblayers.conf`
- `BBFILE_PRIORITY = "10"` — priority cao hơn các layer base (thường là 6) để override được

---

### Bước 3: Tạo machine config

> ⚠️ **Lỗi đã gặp lần 1:** Dùng `require conf/machine/imx6ull14x14evk.conf` + set `UBOOT_MACHINE` → lỗi `You cannot use UBOOT_MACHINE and UBOOT_CONFIG at the same time`.  
> ⚠️ **Lỗi đã gặp lần 2:** Dùng `UBOOT_CONFIG:remove` → không có hiệu lực vì base dùng `??=` (weak assign).  
> **Fix:** Không `require` base conf, tự include `imx-base.inc` trực tiếp và chỉ dùng `UBOOT_CONFIG`.

```bash
cat > ~/imx-yocto-new/sources/meta-okmx6ull/conf/machine/okmx6ull-s-emmc.conf << 'EOF'
#@TYPE: Machine
#@NAME: Forlinx OKMX6ULL-S eMMC
#@DESCRIPTION: Forlinx SOM OKMX6ULL-S, i.MX6ULL, DDR3 512MB, eMMC

MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"

include conf/machine/include/imx-base.inc
include conf/machine/include/arm/armv7a/tune-cortexa7.inc

KERNEL_DEVICETREE = "imx6ull-14x14-evk-emmc.dtb"

# Chỉ dùng UBOOT_CONFIG, không dùng UBOOT_MACHINE
UBOOT_CONFIG ?= "emmc"
UBOOT_CONFIG[emmc] = "mx6ull_14x14_evk_emmc_config,sdcard"

MACHINE_FEATURES += "optee"
OPTEE_BIN_EXT = "6ullevk"

SERIAL_CONSOLES = "115200;ttymxc0"
EOF
```

**Giải thích:**
- Không `require imx6ull14x14evk.conf` — base conf đó set cả `UBOOT_CONFIG` lẫn `UBOOT_MACHINE` gây conflict
- Tự include `imx-base.inc` và `tune-cortexa7.inc` thay thế
- `MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"` — khai báo SoC family để các recipe NXP nhận đúng
- `UBOOT_CONFIG ?=` — weak assign, cho phép override từ `local.conf` nếu cần

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
- `CONFIG_SYS_TEXT_BASE=0x87800000` — load address lấy từ IVT header binary Forlinx gốc
- `CONFIG_ENV_IS_IN_MMC=y` + `ENV_DEV=1` — lưu U-Boot environment trên eMMC (mmcblk1)

---

### Bước 5: Tạo U-Boot bbappend với DDR calibration Forlinx

> ⚠️ **Lỗi đã gặp:** Ban đầu dùng patch file skeleton → lỗi `patch does not apply / malformed patch`.  
> **Fix:** Bỏ patch, dùng `sed` trong `do_patch:append` để override trực tiếp `imximage.cfg`.

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

# Override DDR3 calibration values trong imximage.cfg
# Extracted từ Forlinx factory u-boot-emmc.imx DCD table
# DDR timing (MDCFG0/1/2) giống NXP EVK 100%, chỉ khác calibration
do_patch:append:okmx6ull-s-emmc() {
    CFG=${S}/board/freescale/mx6ullevk/imximage.cfg

    # MPZQSWCTRL ZQ calibration: 0x00000004 -> 0x00000001
    sed -i 's/0x021B080C 0x00000004/0x021B080C 0x00000001/' ${CFG}

    # MPDGHWST0 DQS gating delay: 0x41640158 -> 0x01480158
    sed -i 's/0x021B083C 0x41640158/0x021B083C 0x01480158/' ${CFG}

    # MPRDDLCTL read DQ delay: 0x40403237 -> 0x40403034
    sed -i 's/0x021B0848 0x40403237/0x021B0848 0x40403034/' ${CFG}

    # MPWRDLCTL write DQ delay: 0x40403C33 -> 0x40403A34
    sed -i 's/0x021B0850 0x40403C33/0x021B0850 0x40403A34/' ${CFG}

    # MDMISC RALAT=3: 0x00201740 -> 0x00211740
    sed -i 's/0x021B0018 0x00201740/0x021B0018 0x00211740/' ${CFG}

    echo "=== Forlinx DDR3 calibration applied ==="
    grep "021B080C\|021B083C\|021B0848\|021B0850\|021B0018" ${CFG}
}
EOF
```

---

### Bước 6: Thêm layer vào `bblayers.conf`

> ⚠️ **Lỗi đã gặp:** Dùng `echo '  ${BSPDIR}/sources/meta-okmx6ull \\'` → lỗi `ParseError: unparsed line` vì append ra ngoài block `BBLAYERS = " "`.  
> **Fix:** Dùng `BBLAYERS +=` riêng biệt.

```bash
# Xóa dòng lỗi cũ nếu có
sed -i '/meta-okmx6ull/d' ~/imx-yocto-new/build-fb/conf/bblayers.conf

# Thêm đúng cú pháp
echo 'BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"' >> \
    ~/imx-yocto-new/build-fb/conf/bblayers.conf

# Kiểm tra — dòng cuối phải là:
# BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"
tail -5 ~/imx-yocto-new/build-fb/conf/bblayers.conf
```

---

### Bước 7: Đổi MACHINE trong `local.conf`

```bash
sed -i "s/MACHINE ??= 'imx6ull14x14evk'/MACHINE ??= 'okmx6ull-s-emmc'/" \
    ~/imx-yocto-new/build-fb/conf/local.conf

# Kiểm tra — phải thấy:
# MACHINE ??= 'okmx6ull-s-emmc'
# DISTRO ?= 'fsl-imx-fb'
grep -E 'MACHINE|DISTRO' ~/imx-yocto-new/build-fb/conf/local.conf
```

---

### Bước 8: Build U-Boot

```bash
cd ~/imx-yocto-new
source setup-environment build-fb

# Clean trước khi build (quan trọng sau mỗi lần thay đổi config)
bitbake -c cleansstate u-boot-imx

# Build
bitbake u-boot-imx
```

**Kết quả expected:**
```
NOTE: Tasks Summary: Attempted 842 tasks of which 823 didn't need to be rerun and all succeeded.
```

Trong log build phải thấy calibration đã apply:
```
=== Forlinx DDR3 calibration applied ===
DATA 4 0x021B080C 0x00000001   ✓ MPZQSWCTRL
DATA 4 0x021B083C 0x01480158   ✓ MPDGHWST0
DATA 4 0x021B0848 0x40403034   ✓ MPRDDLCTL
DATA 4 0x021B0850 0x40403A34   ✓ MPWRDLCTL
DATA 4 0x021B0018 0x00211740   ✓ MDMISC RALAT=3
```

---

### Bước 9: Kiểm tra output và copy để flash

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

## Tổng hợp lỗi đã gặp và cách fix

| Lỗi | Nguyên nhân | Fix |
|-----|-------------|-----|
| `ParseError: unparsed line` | Append sai cú pháp vào `bblayers.conf` | Dùng `BBLAYERS += "..."` thay vì echo vào giữa block |
| `Layer depends on meta-freescale but not enabled` | `LAYERDEPENDS` khai báo layer đã có nhưng Yocto không nhận | Đổi thành `LAYERDEPENDS = "core"` |
| `Nothing PROVIDES u-boot-imx` (lần 1) | `UBOOT_MACHINE` và `UBOOT_CONFIG` conflict | Bỏ `UBOOT_MACHINE`, chỉ dùng `UBOOT_CONFIG` |
| `Nothing PROVIDES u-boot-imx` (lần 2) | `UBOOT_CONFIG:remove` không có hiệu lực với `??=` | Không `require` base conf, tự include `imx-base.inc` trực tiếp |
| `patch does not apply / malformed patch` | Patch skeleton không phải patch thật | Bỏ patch, dùng `sed` trong `do_patch:append` |

---

## Bước tiếp theo

- [ ] Flash `u-boot-okmx6ull.imx` lên board qua `uuu`
- [ ] Verify boot log serial: phải thấy `DRAM: 512 MiB`
- [ ] Tạo DTB riêng cho Forlinx (`imx6ull-okmx6ull-s-emmc.dts`) nếu peripheral không đúng
- [ ] Build full image: `bitbake core-image-minimal`
- [ ] Config kernel cho đúng peripheral Forlinx (Ethernet PHY, CAN, LCD...)
- [ ] Implement A/B OTA update với U-Boot bootcount + fw_setenv

---

## Giải thích chi tiết các trường Calibration

### So sánh giá trị NXP EVK vs Forlinx

| Register | Địa chỉ | NXP EVK | Forlinx | Khác biệt |
|----------|---------|---------|---------|-----------|
| MDMISC | 0x021B0018 | 0x00201740 (RALAT=2) | 0x00211740 (RALAT=3) | +1 cycle latency |
| MPZQSWCTRL | 0x021B080C | 0x00000004 (period=4) | 0x00000001 (period=1) | ZQ cal thường xuyên hơn |
| MPDGHWST0 | 0x021B083C | 0x41640158 | 0x01480158 | Sai lớn nhất — DQS timing lệch |
| MPRDDLCTL | 0x021B0848 | 0x40403237 | 0x40403034 | ~2 tick nhỏ hơn — trace ngắn hơn |
| MPWRDLCTL | 0x021B0850 | 0x40403C33 | 0x40403A34 | ~2 tick khác — trace khác |

---

### Ý nghĩa từng trường

#### MDMISC — RALAT (Read Additional Latency)

```
NXP EVK:  RALAT = 2  →  SoC chờ 2 cycle bổ sung sau khi đọc
Forlinx:  RALAT = 3  →  SoC chờ 3 cycle bổ sung sau khi đọc
                                          ↑
                          PCB Forlinx có đường mạch dài hơn
                          tín hiệu đi chậm hơn → cần chờ thêm 1 cycle
```

Đây là **nguyên nhân chính** khiến U-Boot NXP EVK không boot được trên Forlinx.
Sai RALAT → SoC đọc data khi tín hiệu chưa ổn định → toàn bộ DDR init fail.

---

#### MPZQSWCTRL — ZQ Calibration

```
ZQ calibration = mạch tự hiệu chỉnh trở kháng đầu ra của chip DDR3
                 để khớp với trở kháng đường mạch trên PCB

NXP EVK:  period = 4  →  chạy ZQ calibration mỗi 4 đơn vị thời gian
Forlinx:  period = 1  →  chạy ZQ calibration thường xuyên hơn
                          đảm bảo ổn định khi nhiệt độ thay đổi
```

---

#### MPDGHWST0 — DQS Gating Delay

```
DQS (Data Strobe) = tín hiệu đồng hồ đi kèm với data DDR3

DQS gating = "cửa sổ thời gian" SoC mở ra để lấy mẫu data
             chỉ trong khoảng rất ngắn khi DQS đúng pha

NXP EVK:  0x41640158  ─┐
                        ├─ Khác hoàn toàn vì PCB layout khác
Forlinx:  0x01480158  ─┘  → cửa sổ lấy mẫu phải dịch đi

Sai cái này = đọc toàn bộ data sai → board treo ngay lập tức
```

Đây là trường có **sự khác biệt lớn nhất** giữa NXP EVK và Forlinx.

---

#### MPRDDLCTL — Read DQ Delay

```
DQ = các đường data (D0..D15) từ DDR3 về SoC

Read delay = độ trễ bù thêm khi đọc data
             phụ thuộc độ dài vật lý đường mạch DQ trên PCB

NXP EVK:  0x40403237  →  delay = 0x32 / 0x37
Forlinx:  0x40403034  →  delay = 0x30 / 0x34

Forlinx nhỏ hơn ~2 tick vì đường mạch DQ ngắn hơn
→ tín hiệu về nhanh hơn → cần bù ít hơn
```

---

#### MPWRDLCTL — Write DQ Delay

```
Write delay = độ trễ bù thêm khi ghi data từ SoC → DDR3
              tương tự Read delay nhưng chiều ngược lại

NXP EVK:  0x40403C33  →  delay = 0x3C / 0x33
Forlinx:  0x40403A34  →  delay = 0x3A / 0x34

Khác nhau do độ dài đường mạch và driver strength khác nhau trên PCB Forlinx
```

---

### Tóm tắt — Tại sao phải dùng calibration của Forlinx

```
Cùng chip DDR3, cùng timing (MDCFG0/1/2)
NHƯNG mỗi board PCB có:
  - Độ dài đường mạch khác nhau
  - Trở kháng khác nhau
  - Nhiệt độ hoạt động khác nhau

→ Tín hiệu điện đến sớm/muộn hơn vài nano-giây
→ Phải hiệu chỉnh (calibrate) lại thời điểm lấy mẫu
→ Dùng calibration NXP EVK cho PCB Forlinx = đọc/ghi sai thời điểm
→ Kết quả: board không boot hoặc RAM không ổn định
```