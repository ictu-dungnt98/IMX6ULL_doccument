                                CÁCH BUILD UBOOT OKMX6ULL-S CHUẨN TIMING CHO DDR3


I.Lý do em chọn phương pháp này
    -Vì forlinx không cũng cấp bsp trực tiếp để gắn vào yocto như nxp. 
=>> Nên em đã build Uboot dựa trên yocto bsp NXP trên con chip giống với chip của board OKMX6ULL-S (imx6ull 14x14 evk)


II. các bước config 

- Để xem chi tiết hơn hãy vào: (/AI_flow_gennerate_pass/how_to_custom_uboot_for_SOM_forlinx.md)

1.1: Câu lệnh em đã sử dụng 
- ở đây em chỉ giải thích các lệnh tại sao dùng và tại sao phải chỉnh.
    - xem cách để kéo repo về và bung file ra tại (NXP_IMX6ULL_EVK/build_image/general_setup.md)
    sau khi bung file ra song (hơi lâu) phải tạo ra meta reeng để sau này vá config và lấy file sửa các files đơn giản hơn 

cd ~/imx-yocto-new/sources
mkdir -p meta-okmx6ull/conf/machine
mkdir -p meta-okmx6ull/recipes-bsp/u-boot/files

(lệnh này là tạo ra thư mục chứa src meta-okmx6ull ở đây là làm theo chuẩn của yocto nên quy ước nên tạo như vậy

để nhét các file như layer.conf để bitbake vào đây đọc đầu tiên để nói xem layer này là gì 

- và thư mục machine để bitbake tìm đúng machine để tìm đúng đường dẫn như kiểu chỉ đường cho bitbake
recipes-bsp chính là quy ước để  đặt tên recipes-<category> thư mục này sẽ chứa các thư mục con để chứa các cách để bitbake build 
)

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

(lệnh này là để tạo ra files layer.conf files này sẽ chứa các thông tin để cho biết layer meta-okmx6ull tồn tại và hoạt động như nào 
    +BBPATH .= ":${LAYERDIR}" Thêm thư mục của layer vào search path của bitbake. ${LAYERDIR} tự động trỏ đến ~/imx-yocto-new/sources/meta-okmx6ull. Nhờ dòng này bitbake mới biết đường đi vào layer để tìm các file bên trong.
    +BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"
            Khai báo pattern để bitbake tìm recipe. Dòng này nói: "tất cả file .bb và .bbappend nằm trong bất kỳ thư mục recipes-xxx/yyy/ nào đều là recipe của layer này". Nhờ đó bitbake tự động tìm thấy recipes-bsp/u-boot/u-boot-imx_%.bbappend mà không cần khai báo từng file.
    +BBFILE_COLLECTIONS += "meta-okmx6ull"
        BBFILE_PATTERN_meta-okmx6ull = "^${LAYERDIR}/"
        Đặt tên định danh cho collection này và khai báo pattern nhận diện. Bitbake dùng cặp này để biết file nào thuộc layer nào khi có nhiều layer cùng lúc — tránh nhầm lẫn giữa các layer.
    +BBFILE_PRIORITY_meta-okmx6ull = "10"
        Độ ưu tiên của layer. Số càng cao càng được ưu tiên. Các layer base của NXP thường là 6, poky là 5 — mày đặt 10 để layer Forlinx override được các config của NXP EVK khi có xung đột.
    +LAYERDEPENDS_meta-okmx6ull = "core"Khai báo layer này phụ thuộc vào layer nào. Chỉ cần core (poky) là đủ. Không khai báo meta-freescale dù có dùng — vì meta-freescale đã có trong bblayers.conf rồi, khai báo thêm ở đây sẽ bị lỗi Layer depends on meta-freescale but not enabled.
    +LAYERSERIES_COMPAT_meta-okmx6ull = "kirkstone" Khai báo layer này tương thích với Yocto version nào. Nếu mày dùng layer này với Yocto khác version (ví dụ Scarthgap) bitbake sẽ cảnh báo không tương thích. Giúp tránh lỗi khó debug khi upgrade Yocto sau này.
)



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

    (lệnh này là để  
        + MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"
        Khai báo SoC family cho board này. Dấu =. nghĩa là prepend — thêm vào đầu chuỗi. Ba prefix mx6, mx6ul, mx6ull cho phép bitbake nhận diện đây là chip i.MX6ULL và áp dụng đúng các bbappend của NXP. Thiếu dòng này → các recipe NXP không biết board này thuộc dòng chip nào → build sai hoặc thiếu driver.
        + include conf/machine/include/imx-base.inc
        include conf/machine/include/arm/armv7a/tune-cortexa7.inc

        include hau file chung config cho các board imx
        imx-base.inc — các setting chung cho tất cả board i.MX: compiler flags, image type, boot config
        tune-cortexa7.inc — tối ưu compiler cho CPU Cortex-A7 của i.MX6ULL: NEON, VFP, thumb instruction set
        
        + KERNEL_DEVICETREE = "imx6ull-14x14-evk-emmc.dtb"
        Tên file DTB kernel sẽ build và dùng để boot. Tạm thời dùng DTB của NXP EVK vì hardware rất gần nhau. Sau này khi cần custom peripheral riêng của Forlinx thì tạo DTB mới thay vào đây.
        
        + UBOOT_CONFIG ?= "emmc"
        UBOOT_CONFIG[emmc] = "mx6ull_14x14_evk_emmc_config,sdcard"
        ?= là weak assign — chỉ set nếu chưa có giá trị, cho phép override từ local.conf
        UBOOT_CONFIG[emmc] — tên defconfig U-Boot sẽ dùng là mx6ull_14x14_evk_emmc_config, output format là sdcard
        Chỉ dùng UBOOT_CONFIG không dùng UBOOT_MACHINE — vì dùng cả hai cùng lúc bitbake báo lỗi You cannot use UBOOT_MACHINE and UBOOT_CONFIG at the same time
        
        + MACHINE_FEATURES += "optee"
        OPTEE_BIN_EXT = "6ullevk"
        Bật tính năng OP-TEE (Trusted Execution Environment) — môi trường bảo mật chạy song song với Linux. OPTEE_BIN_EXT = "6ullevk" trỏ đến binary OP-TEE prebuilt của NXP cho dòng EVK. Cần thiết vì imx-base.inc có một số logic phụ thuộc vào optee.

        +SERIAL_CONSOLES = "115200;ttymxc0"
        Khai báo cổng serial console: baudrate 115200, device ttymxc0 tức UART1 của i.MX6ULL. Kernel sẽ in log boot ra đây, đây cũng là terminal để mày debug khi board không boot được.
)   

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

(lệnh này là để 
+CONFIG_ARM=y
CONFIG_ARCH_MX6=y
CONFIG_MX6ULL=y
CONFIG_TARGET_MX6ULL_14X14_EVK=y
Khai báo đây là chip ARM, dòng i.MX6, cụ thể là i.MX6ULL, dùng board code của NXP EVK 14x14 làm base. U-Boot dùng 4 dòng này để chọn đúng source code board trong board/freescale/mx6ullevk/.

+CONFIG_SYS_TEXT_BASE=0x87800000   ← U-Boot load vào địa chỉ RAM này lệnh này quan trongj vì SYS_TEXT_BASE=0x87800000 lấy từ IVT header binary Forlinx gốc — phải khớp chính xác, sai địa chỉ này U-Boot sẽ tự ghi đè lên chính nó và crash.
CONFIG_SYS_MALLOC_LEN=0x1000000   ← 16MB heap cho malloc trong U-Boot
CONFIG_SYS_LOAD_ADDR=0x80800000   ← địa chỉ mặc định load kernel vào RAM

+ CONFIG_ENV_IS_IN_MMC=y        ← lưu env trên eMMC, không phải NAND/NOR
CONFIG_ENV_SIZE=0x2000        ← kích thước vùng env = 8KB
CONFIG_ENV_OFFSET=0x400000    ← env nằm ở offset 4MB trên eMMC
CONFIG_ENV_SECT_SIZE=0x20000  ← sector size = 128KB
CONFIG_SYS_MMC_ENV_DEV=1      ← mmcblk1 (eMMC), không phải mmcblk0 (SD)
CONFIG_SYS_MMC_ENV_PART=1     ← lưu ở boot partition của eMMC

Nhóm này quyết định fw_setenv/fw_printenv đọc/ghi env ở đâu trên eMMC — quan trọng cho hệ thống A/B OTA sau này.


+CONFIG_CMD_MMC=y    ← lệnh mmc (đọc/ghi eMMC, SD)
CONFIG_CMD_FAT=y    ← đọc partition FAT32 (nơi chứa zImage, DTB)
CONFIG_CMD_EXT4=y   ← đọc partition ext4 (rootfs)
CONFIG_CMD_USB=y    ← hỗ trợ USB host
CONFIG_CMD_DHCP=y   ← lấy IP qua DHCP (boot qua mạng)
CONFIG_CMD_PING=y   ← lệnh ping để test mạng
CONFIG_CMD_GPIO=y   ← điều khiển GPIO từ U-Boot prompt
CONFIG_CMD_I2C=y    ← giao tiếp I2C từ U-Boot prompt
Mỗi CONFIG_CMD_xxx=y thêm một lệnh vào U-Boot shell. Chỉ bật những gì cần — bật thừa tốn flash space.

+ CONFIG_MMC=y
CONFIG_FSL_ESDHC_IMX=y   ← driver ESDHC của Freescale/NXP
CONFIG_FSL_USDHC=y        ← driver uSDHC (SD/eMMC controller trên i.MX6ULL)
CONFIG_DM_MMC=y           ← dùng Driver Model cho MMC

Cần đủ 4 dòng này thì U-Boot mới nhận được eMMC để load kernel.

+CONFIG_PHYLIB=y     ← thư viện PHY layer (giao tiếp với chip Ethernet PHY)
CONFIG_FEC_MXC=y    ← driver FEC (Fast Ethernet Controller) của i.MX6ULL
CONFIG_MII=y        ← giao thức MII để SoC nói chuyện với PHY chip
CONFIG_DM_ETH=y     ← dùng Driver Model cho Ethernet
Cần thiết để dùng lệnh dhcp, ping, hoặc boot qua TFTP khi debug.


+ CONFIG_DEFAULT_DEVICE_TREE="imx6ull-okmx6ull-s-emmc"  ← tên DTB mặc định
CONFIG_OF_CONTROL=y      ← U-Boot dùng DTB để cấu hình hardware
CONFIG_OF_BOARD_SETUP=y  ← cho phép board code sửa DTB trước khi truyền cho kernel
CONFIG_DM=y              ← bật Driver Model (kiến trúc driver hiện đại của U-Boot)
CONFIG_DM_GPIO=y
CONFIG_DM_I2C=y

CONFIG_DISTRO_DEFAULTS=y — bật bộ config chuẩn cho distro boot: tự động tìm kernel trên các partition theo thứ tự ưu tiên, hỗ trợ boot.scr, tương thích với Yocto image layout.
)


* lưu ý lệnh này rất quan trọng 
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


(lệnh này dùng để 

    +FILESEXTRAPATHS:prepend := "${THISDIR}/files:"${THISDIR} = thư mục chứa file bbappend này, tức recipes-bsp/u-boot/. Dòng này nói với bitbake: "tìm file đính kèm trong thư mục files/ cạnh file bbappend này trước". Thiếu dòng này bitbake không tìm thấy defconfig → build fail.

    +SRC_URI:append:okmx6ull-s-emmc = " \
    file://okmx6ull_s_emmc_defconfig \
    "
    :append:okmx6ull-s-emmc — chỉ áp dụng khi MACHINE = "okmx6ull-s-emmc", không ảnh hưởng machine khác. file:// prefix nói bitbake tìm file này trong FILESEXTRAPATHS — tức thư mục files/ vừa khai báo ở trên.

    +do_configure:append:okmx6ull-s-emmc() {
    cp ${WORKDIR}/okmx6ull_s_emmc_defconfig \
       ${S}/configs/okmx6ull_s_emmc_defconfig
    }

        do_configure:append  ← chạy THÊM sau khi task configure gốc của NXP xong
    ${WORKDIR}           ← thư mục bitbake giải nén/copy các file SRC_URI vào
                        ~/build-fb/tmp/work/okmx6ull_s_emmc-.../u-boot-imx/2022.04-r0/
    ${S}                 ← thư mục source code U-Boot đã được checkout
                        ${WORKDIR}/git/


    U-Boot yêu cầu defconfig phải nằm trong configs/ bên trong source tree. Bitbake copy file từ files/ vào ${WORKDIR} nhưng không tự đặt vào configs/ — mày phải cp tay như vầy.

    +do_patch:append:okmx6ull-s-emmc() {
    CFG=${S}/board/freescale/mx6ullevk/imximage.cfg

    do_patch:append — chạy sau khi bitbake apply tất cả patch gốc của NXP xong. Chọn hook này vì lúc này source code đã sẵn sàng nhưng chưa compile. CFG là shortcut trỏ đến file imximage.cfg — nơi chứa DCD table với các giá trị DDR calibration của NXP EVK.

    +sed -i 's/0x021B080C 0x00000004/0x021B080C 0x00000001/' ${CFG}
    sed -i 's/0x021B083C 0x41640158/0x021B083C 0x01480158/' ${CFG}
    sed -i 's/0x021B0848 0x40403237/0x021B0848 0x40403034/' ${CFG}
    sed -i 's/0x021B0850 0x40403C33/0x021B0850 0x40403A34/' ${CFG}
    sed -i 's/0x021B0018 0x00201740/0x021B0018 0x00211740/' ${CFG}

    sed -i — edit file trực tiếp (in-place), không tạo file mới. 's/cũ/mới/' — tìm chuỗi cũ thay bằng chuỗi mới. Mỗi dòng thay đúng 1 register calibration NXP → Forlinx:


    +echo "=== Forlinx DDR3 calibration applied ==="
    grep "021B080C\|021B083C\|021B0848\|021B0850\|021B0018" ${CFG}

    In ra 5 dòng register vừa sửa để mày xác nhận trong build log là sed đã chạy đúng. Nếu không thấy dòng này trong log → do_patch không chạy → cần debug lại.
)




# Xóa dòng lỗi cũ nếu có
sed -i '/meta-okmx6ull/d' ~/imx-yocto-new/build-fb/conf/bblayers.conf

# Thêm đúng cú pháp
echo 'BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"' >> \
    ~/imx-yocto-new/build-fb/conf/bblayers.conf

# Kiểm tra — dòng cuối phải là:
# BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"
tail -5 ~/imx-yocto-new/build-fb/conf/bblayers.conf

(lệnh này là để  
 +sed -i '/meta-okmx6ull/d' ~/imx-yocto-new/build-fb/conf/bblayers.conf
    sed -i '/pattern/d' — tìm tất cả dòng chứa meta-okmx6ull và xóa đi, edit trực tiếp file. Cần thiết vì lần đầu tao hướng dẫn dùng lệnh echo sai cú pháp đã append một dòng lỗi vào bblayers.conf:


+# Dòng lỗi cũ trông như vầy — nằm ngoài block BBLAYERS
  ${BSPDIR}/sources/meta-okmx6ull \\

  Bitbake đọc file này gặp dòng đó báo ngay ParseError: unparsed line và từ chối build. Lệnh sed này dọn sạch trước khi thêm lại đúng cách.


+echo 'BBLAYERS += "${BSPDIR}/sources/meta-okmx6ull"' >> \
    ~/imx-yocto-new/build-fb/conf/bblayers.conf
    >> — append vào cuối file, không ghi đè. BBLAYERS += — cú pháp Yocto để thêm một layer vào danh sách, có thể đứng độc lập ngoài block BBLAYERS = " " ban đầu.
${BSPDIR}  ← biến Yocto trỏ đến ~/imx-yocto-new
            được định nghĩa sẵn trong bblayers.conf gốc của NXP
            dùng biến thay vì hardcode path tuyệt đối
            → ai clone repo về máy khác vẫn chạy được
Tại sao lần đầu bị lỗi: Lệnh echo cũ thêm dòng có \\ ở cuối và nằm ngoài block BBLAYERS = " \\ ... " của Yocto — bitbake không parse được vì cú pháp block multiline đó đã đóng rồi. Dùng BBLAYERS += là cách đúng để thêm layer bên ngoài block.


)
