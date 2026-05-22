# CÁCH BUILD UBOOT OKMX6ULL-S CHUẨN TIMING CHO DDR3

# I. Lý do em chọn phương pháp này

* Vì Forlinx không cung cấp BSP trực tiếp để gắn vào Yocto như NXP.

=> Nên em đã build U-Boot dựa trên Yocto BSP của NXP trên con chip giống với chip của board OKMX6ULL-S (`i.MX6ULL 14x14 EVK`).

---

# II. Ý tưởng chính của phương pháp này

Em không viết board support mới hoàn toàn cho Forlinx từ đầu.

Mà em:

* lấy nguyên board support package của NXP EVK 14x14 ra làm base
* sau đó sửa lại:

  * DDR3 calibration
  * machine config
  * U-Boot config
  * device tree
  * boot config

---

# III. Tại sao phải làm như vậy

Board OKMX6ULL-S:

* dùng cùng SoC i.MX6ULL
* DDR3 gần tương đương
* clock architecture gần giống
* power tree gần giống NXP EVK

nên có thể reuse:

* DDR init
* PMIC init
* clock init
* pinmux
* boot init

của NXP.

---

# IV. Nhưng vấn đề lớn nhất là DDR3 timing

Timing DDR3:

* không bao giờ giống hoàn toàn giữa 2 board
* vì còn phụ thuộc:

  * PCB routing
  * trace length
  * impedance
  * layout
  * DDR chip vendor

Nên nếu dùng nguyên calibration của NXP:

* có thể boot được
* nhưng dễ:

  * random crash
  * kernel panic
  * memory corruption
  * boot fail ngẫu nhiên

---

# V. Giải pháp em sử dụng

Em:

* giữ nguyên timing cơ bản của NXP
* chỉ patch các giá trị calibration của DDR3 theo đúng board Forlinx

Thông qua:

* patch file `imximage.cfg`
* override DCD table
* thay register calibration

---

# VI. Flow tổng thể

```text
Lấy BSP Yocto của NXP
            ↓
Tạo custom meta layer cho Forlinx
            ↓
Reuse board support của NXP EVK
            ↓
Patch DDR calibration của Forlinx
            ↓
Build lại bằng BitBake
            ↓
Sinh ra U-Boot ổn định cho OKMX6ULL-S
```

---

# VII. Các bước config

* Để xem chi tiết hơn hãy vào:

```text
/AI_flow_gennerate_pass/how_to_custom_uboot_for_SOM_forlinx.md
```

* xem cách để kéo repo về và bung file ra tại:

```text
NXP_IMX6ULL_EVK/build_image/general_setup.md
```

---

# VIII. Sau khi sync source Yocto

Sau khi bung source ra xong (hơi lâu) thì phải tạo meta layer riêng để:

* vá config
* patch DDR timing
* override machine
* sửa file đơn giản hơn
* không sửa trực tiếp BSP gốc của NXP

---

# IX. Tạo custom meta layer

```bash
cd ~/imx-yocto-new/sources

mkdir -p meta-okmx6ull/conf/machine

mkdir -p meta-okmx6ull/recipes-bsp/u-boot/files
```

(lệnh này là tạo ra thư mục chứa src meta-okmx6ull ở đây là làm theo chuẩn của yocto nên quy ước nên tạo như vậy

để nhét các file như layer.conf để bitbake vào đây đọc đầu tiên để nói xem layer này là gì

* và thư mục machine để bitbake tìm đúng machine để tìm đúng đường dẫn như kiểu chỉ đường cho bitbake

recipes-bsp chính là quy ước để đặt tên `recipes-<category>`

thư mục này sẽ chứa các thư mục con để chứa các cách để bitbake build
)

---

# X. Tạo file layer.conf

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

(lệnh này là để tạo ra files layer.conf files này sẽ chứa các thông tin để cho biết layer meta-okmx6ull tồn tại và hoạt động như nào

* `BBPATH .= ":${LAYERDIR}"`

Thêm thư mục của layer vào search path của bitbake.

`${LAYERDIR}` tự động trỏ đến:

```text
~/imx-yocto-new/sources/meta-okmx6ull
```

Nhờ dòng này bitbake mới biết đường đi vào layer để tìm các file bên trong.

---

* `BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"`

Khai báo pattern để bitbake tìm recipe.

Dòng này nói:

* tất cả file `.bb`
* `.bbappend`

nằm trong bất kỳ thư mục:

* `recipes-xxx/yyy/`

đều là recipe của layer này.

---

* `BBFILE_COLLECTIONS += "meta-okmx6ull"`

`BBFILE_PATTERN_meta-okmx6ull = "^${LAYERDIR}/"`

Đặt tên định danh cho collection này và khai báo pattern nhận diện.

Bitbake dùng cặp này để biết file nào thuộc layer nào khi có nhiều layer cùng lúc — tránh nhầm lẫn giữa các layer.

---

* `BBFILE_PRIORITY_meta-okmx6ull = "10"`

Độ ưu tiên của layer.

Số càng cao càng được ưu tiên.

Các layer base của NXP thường là:

* 6
* poky là 5

mày đặt 10 để layer Forlinx override được các config của NXP EVK khi có xung đột.

---

* `LAYERDEPENDS_meta-okmx6ull = "core"`

Khai báo layer này phụ thuộc vào layer nào.

Chỉ cần core (poky) là đủ.

Không khai báo meta-freescale dù có dùng — vì meta-freescale đã có trong bblayers.conf rồi.

---

* `LAYERSERIES_COMPAT_meta-okmx6ull = "kirkstone"`

Khai báo layer này tương thích với Yocto version nào.

Nếu mày dùng layer này với Yocto khác version (ví dụ Scarthgap) bitbake sẽ cảnh báo không tương thích.
)

---

# XI. Tạo machine config

```bash
cat > ~/imx-yocto-new/sources/meta-okmx6ull/conf/machine/okmx6ull-s-emmc.conf << 'EOF'
#@TYPE: Machine
#@NAME: Forlinx OKMX6ULL-S eMMC
#@DESCRIPTION: Forlinx SOM OKMX6ULL-S, i.MX6ULL, DDR3 512MB, eMMC

MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"

include conf/machine/include/imx-base.inc
include conf/machine/include/arm/armv7a/tune-cortexa7.inc

KERNEL_DEVICETREE = "imx6ull-14x14-evk-emmc.dtb"

UBOOT_CONFIG ?= "emmc"
UBOOT_CONFIG[emmc] = "mx6ull_14x14_evk_emmc_config,sdcard"

MACHINE_FEATURES += "optee"
OPTEE_BIN_EXT = "6ullevk"

SERIAL_CONSOLES = "115200;ttymxc0"
EOF
```

(lệnh này là để

* `MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"`

Khai báo SoC family cho board này.

Ba prefix:

* mx6
* mx6ul
* mx6ull

cho phép bitbake nhận diện đây là chip i.MX6ULL và áp dụng đúng các bbappend của NXP.

---

* `include conf/machine/include/imx-base.inc`

`include conf/machine/include/arm/armv7a/tune-cortexa7.inc`

include hai file chung config cho các board imx

* `imx-base.inc`

  * compiler flags
  * image type
  * boot config

* `tune-cortexa7.inc`

  * tối ưu compiler cho Cortex-A7

---

* `KERNEL_DEVICETREE = "imx6ull-14x14-evk-emmc.dtb"`

Tạm thời dùng DTB của NXP EVK vì hardware rất gần nhau.

---

* `UBOOT_CONFIG ?= "emmc"`

`UBOOT_CONFIG[emmc] = "mx6ull_14x14_evk_emmc_config,sdcard"`

Khai báo defconfig của U-Boot.

---

* `MACHINE_FEATURES += "optee"`

Enable OP-TEE support.

---

* `SERIAL_CONSOLES = "115200;ttymxc0"`

UART debug console.
)

---

# XII. Tạo custom U-Boot defconfig

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

(lệnh này là để

* `CONFIG_TARGET_MX6ULL_14X14_EVK=y`

Đây là phần rất quan trọng vì thực tế em KHÔNG viết board support mới hoàn toàn cho Forlinx từ đầu.

Mà em lấy nguyên board support package của NXP EVK 14x14 ra làm base rồi sửa lại cho phù hợp với hardware của Forlinx.

Khi bật:

```text
CONFIG_TARGET_MX6ULL_14X14_EVK=y
```

U-Boot sẽ:

* dùng source code board của NXP
* dùng DDR init code của NXP
* dùng clock init của NXP
* dùng PMIC init của NXP
* dùng pinmux của NXP
* dùng toàn bộ board directory của EVK

Cụ thể nó sẽ build từ:

```text
board/freescale/mx6ullevk/
```

---

Board OKMX6ULL-S:

* dùng cùng SoC i.MX6ULL
* DDR3 gần tương đương
* clock architecture gần giống

nên có thể reuse gần như toàn bộ board init của NXP.

---

Nhưng vấn đề nằm ở DDR3 calibration.

Timing DDR3:

* không bao giờ giống hoàn toàn giữa 2 board
* vì còn phụ thuộc:

  * PCB routing
  * trace length
  * impedance
  * layout

Nên nếu dùng nguyên calibration của NXP:

* có thể boot được
* nhưng dễ:

  * random crash
  * kernel panic
  * memory corruption

---

Vì vậy em không sửa toàn bộ DDR init.

Mà chỉ:

* giữ nguyên timing cơ bản của NXP
* thay đúng các giá trị calibration của Forlinx

Thông qua:

* patch file `imximage.cfg`

---

* `CONFIG_SYS_TEXT_BASE=0x87800000`

U-Boot load vào địa chỉ RAM này.

Phải khớp IVT header binary Forlinx gốc.

Sai địa chỉ:

* U-Boot overwrite chính nó
* crash boot

---

* `CONFIG_SYS_MALLOC_LEN=0x1000000`

Heap cho malloc trong U-Boot.

---

* `CONFIG_ENV_IS_IN_MMC=y`

Lưu environment trên eMMC.

---

* `CONFIG_CMD_MMC=y`
  `CONFIG_CMD_EXT4=y`
  `CONFIG_CMD_FAT=y`

Enable đọc:

* eMMC
* ext4
* FAT32

---

* `CONFIG_CMD_DHCP=y`
  `CONFIG_CMD_PING=y`

Enable network debug.

---

* `CONFIG_FSL_ESDHC_IMX=y`
  `CONFIG_FSL_USDHC=y`

Enable driver SD/eMMC controller của NXP.

---

* `CONFIG_DEFAULT_DEVICE_TREE="imx6ull-okmx6ull-s-emmc"`

DTB mặc định U-Boot sẽ load.

---

* `CONFIG_DM=y`

Enable Driver Model của U-Boot.
)

---

# XIII. Patch DDR3 calibration của Forlinx

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

do_patch:append:okmx6ull-s-emmc() {

    CFG=${S}/board/freescale/mx6ullevk/imximage.cfg

    sed -i 's/0x021B080C 0x00000004/0x021B080C 0x00000001/' ${CFG}

    sed -i 's/0x021B083C 0x41640158/0x021B083C 0x01480158/' ${CFG}

    sed -i 's/0x021B0848 0x40403237/0x021B0848 0x40403034/' ${CFG}

    sed -i 's/0x021B0850 0x40403C33/0x021B0850 0x40403A34/' ${CFG}

    sed -i 's/0x021B0018 0x00201740/0x021B0018 0x00211740/' ${CFG}

    echo "=== Forlinx DDR3 calibration applied ==="

    grep "021B080C\|021B083C\|021B0848\|021B0850\|021B0018" ${CFG}
}
EOF
```

(lệnh này dùng để

* `FILESEXTRAPATHS:prepend := "${THISDIR}/files:"`

Cho bitbake tìm file trong thư mục:

* `files/`

---

* `SRC_URI:append:okmx6ull-s-emmc`

Chỉ apply cho machine:

* `okmx6ull-s-emmc`

---

* `do_configure:append`

Copy defconfig vào:

* `${S}/configs/`

vì U-Boot yêu cầu defconfig nằm trong source tree.

---

* `CFG=${S}/board/freescale/mx6ullevk/imximage.cfg`

Đây là file DDR init của NXP EVK.

Em patch trực tiếp calibration của file này.

---

* `sed -i`

Thay các register DDR calibration:

* của NXP
* thành calibration extract từ binary U-Boot gốc của Forlinx.

Các register này thuộc:

* MMDC DDR controller của i.MX6ULL

Ví dụ:

* DQS gating delay
* write leveling
* read delay
* ZQ calibration

---

Flow thật sự là:

```text
Lấy board support NXP EVK
            ↓
Reuse toàn bộ DDR init của NXP
            ↓
Extract calibration từ U-Boot factory của Forlinx
            ↓
Patch lại các register calibration
            ↓
Build lại bằng Yocto
```

)

---

# XIV. Add custom layer vào bblayers.conf

```bash
sed -i '/meta-okmx6ull/d' \
~/imx-yocto-new/build-fb/conf/bblayers.conf
```

```bash
echo 'BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"' >> \
~/imx-yocto-new/build-fb/conf/bblayers.conf
```

```bash
tail -5 ~/imx-yocto-new/build-fb/conf/bblayers.conf
```

Kết quả cuối file phải có:

```text
BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"
```

---

# XV. Tổng kết

Phương pháp này:

* reuse BSP ổn định của NXP
* custom tối thiểu
* patch DDR calibration theo hardware thực tế của Forlinx

Ưu điểm:

* build ổn định
* dễ maintain
* dễ migrate Yocto version
* không sửa trực tiếp source gốc của NXP
