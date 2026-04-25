# i.MX 6UL - Yocto Project User's Guide - Index

> Trích từ: *i.MX Yocto Project User's Guide - Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## 📋 Mục lục

| STT | Chương | Mô tả | File |
|-----|--------|-------|------|
| 1 | [Overview](#1-overview) | Giới thiệu tổng quan về i.MX 6UL, product family, layers hỗ trợ, tài liệu tham khảo | [`i.MX_6UL.md`](i.MX_6UL.md) |
| 2 | [Features](#2-features) | Các tính năng: Linux Kernel, U-Boot, Graphics, Multimedia, các recipe áp dụng cho 6UL | [`i.MX_6UL_Features.md`](i.MX_6UL_Features.md) |
| 3 | [Host Setup](#3-host-setup) | Cài đặt môi trường build host: dung lượng ổ cứng, Docker, host packages | [`i.MX_6UL_Host_Setup.md`](i.MX_6UL_Host_Setup.md) |
| 4 | [Yocto Project Setup](#4-yocto-project-setup) | Tải BSP, cấu trúc thư mục, repo sync | [`i.MX_6UL_Yocto_Project_Setup.md`](i.MX_6UL_Yocto_Project_Setup.md) |
| 5 | [Image Build](#5-image-build) | Build configurations, machine & distro setup, U-Boot config, BitBake options, build scenarios | [`i.MX_6UL_Image_Build.md`](i.MX_6UL_Image_Build.md) |
| 6 | [Image Deployment](#6-image-deployment) | Output files, flash SD card, hướng dẫn deployment | [`i.MX_6UL_Image_Deployment.md`](i.MX_6UL_Image_Deployment.md) |
| 7 | [Customization](#7-customization) | Tạo custom distro, custom board config, giám sát CVE với Vigiles | [`i.MX_6UL_Customization.md`](i.MX_6UL_Customization.md) |
| 8 | [FAQ & Quick Start](#8-faq--quick-start) | Quick start guide, tuning, recipes, package management, log troubleshooting | [`i.MX_6UL_FAQ.md`](i.MX_6UL_FAQ.md) |

---

## 1. Overview

**File:** [`i.MX_6UL.md`](i.MX_6UL.md)

**Nội dung chính:**
- i.MX 6UL thuộc dòng i.MX 6 Family
- Các layer Yocto hỗ trợ: `meta-freescale`, `meta-freescale-distro`, `meta-freescale-3rdparty`, `meta-imx-bsp`
- Danh sách tài liệu tham khảo liên quan (UG10163, UG10164, UG10165, RN00210,...)
- Quick Start Guide cho EVK boards
- Tài nguyên và links (GitHub, BSP layer, manifest)

**Tìm nhanh:**
- BSP layers: Phần **2. Layer hỗ trợ**
- Machine names cho 6UL: Xem bảng trong Chapter 5
- Tài liệu tham khảo: Phần **3. Tài liệu tham khảo liên quan**

---

## 2. Features

**File:** [`i.MX_6UL_Features.md`](i.MX_6UL_Features.md)

**Nội dung chính:**
- Linux Kernel: recipes trong `recipes-kernel`, source `linux-imx.git`
- U-Boot: recipes trong `recipes-bsp`, source `uboot-imx.git` (v2025.04)
- Graphics: Frame Buffer support, GPU Vivant (không có trên 6UL)
- Multimedia: Codec proprietary `imx-codec`, `imx-parser`
- Recipes áp dụng/không áp dụng cho 6UL

**Tìm nhanh:**
- Phiên bản U-Boot: Phần **U-Boot**
- Hỗ trợ GPU: Phần **Graphics** (6UL KHÔNG có GPU)
- Tính năng ML: **Không hỗ trợ** trên 6UL (xem bảng "Không áp dụng")

---

## 3. Host Setup

**File:** [`i.MX_6UL_Host_Setup.md`](i.MX_6UL_Host_Setup.md)

**Nội dung chính:**
- Yêu cầu dung lượng ổ cứng theo backend (50GB, 120GB, 250GB)
- Ubuntu 22.04 trở lên tối thiểu
- Docker support (imx-docker repo)
- Cài đặt host packages với apt-get

**Tính năng quan trọng:**
- Frame Buffer chỉ i.MX 6/7 → 6UL có lợi thế
- Docker on-board: chỉ i.MX 8, không áp dụng cho 6UL

**Lệnh cài đặt host packages:**
```bash
sudo apt-get install build-essential chrpath cpio debianutils diffstat \
  file gawk git iputils-ping libacl1 liblz4-tool locales python3 \
  python3-git python3-jinja2 python3-pexpect python3-pip \
  python3-subunit socat texinfo unzip wget xz-utils zstd efitools
```

---

## 4. Yocto Project Setup

**File:** [`i.MX_6UL_Yocto_Project_Setup.md`](i.MX_6UL_Yocto_Project_Setup.md)

**Nội dung chính:**
- Cấu trúc thư mục BSP: `sources/` chứa layers và recipes
- Lệnh repo init và repo sync
- Manifest files tại `imx-manifest` repository

**Lệnh tải BSP:**
```bash
mkdir imx-yocto-bsp
cd imx-yocto-bsp
repo init -u https://github.com/nxp-imx/imx-manifest \
    -b imx-linux-whinlatter \
    -m imx-6.18.2-1.0.0.xml
repo sync
```

**Branch:** `imx-linux-whinlatter` (Yocto Project 5.3)

---

## 5. Image Build

**File:** [`i.MX_6UL_Image_Build.md`](i.MX_6UL_Image_Build.md)

**Nội dung chính:**
- **5.1 Build Configurations:**
  - Machine: `imx6ulevk`, `imx6ulz-14x14-evk`, `imx6ull14x14evk`, `imx6ull9x9evk`
  - DISTRO: `fsl-imx-wayland`, `fsl-imx-xwayland`, `fsl-imx-fb` (Frame Buffer)
  - Cú pháp: `DISTRO=<distro> MACHINE=<machine> source imx-setup-release.sh -b <build dir>`

- **5.2 Chọn Image:**
  - `core-image-minimal` ✅
  - `core-image-base` ✅
  - `fsl-image-machinetest` ✅
  - `imx-image-core` ✅
  - `imx-image-multimedia` ✅
  - `imx-image-full` ❌ **KHÔNG hỗ trợ 6UL** (yêu cầu GPU)

- **5.3 Build Image:** `bitbake imx-image-multimedia`

- **5.4 BitBake Options:** `-c fetch`, `-c cleanall`, `-c deploy`, `-k`, `-c compile -f`, `-g`, `-DDD`, `-s`

- **5.5 U-Boot Config:** Bảng config cho từng board (`sd`, `emmc`, `qspi1`, `sd-optee`)

- **5.6 Build Scenarios:** Ví dụ đầy đủ cho 6UL

- **5.7 Tính năng bổ sung:** OP-TEE (bật mặc định), Systemd (bật mặc định)

**Ví dụ build Frame Buffer:**
```bash
DISTRO=fsl-imx-fb MACHINE=imx6ulevk source imx-setup-release.sh -b build-fb
bitbake imx-image-multimedia
```

---

## 6. Image Deployment

**File:** [`i.MX_6UL_Image_Deployment.md`](i.MX_6UL_Image_Deployment.md)

**Nội dung chính:**
- Output directory: `/tmp/deploy/images/`
- Các file được tạo: U-Boot, Kernel, SD card image (`.wic`), Rootfs image (`.tar`)

**Flash SD card:**
```bash
zstdcat <image>.wic.zst | sudo dd of=/dev/sd<X> bs=1M conv=fsync
```

**Lưu ý:**
- `.wic` file đã bao gồm U-Boot, kernel, rootfs
- 6UL không cần dung lượng cho eIQ ML (không hỗ trợ)

---

## 7. Customization

**File:** [`i.MX_6UL_Customization.md`](i.MX_6UL_Customization.md)

**Nội dung chính:**
- **7.1 Tạo Custom Distro:** Copy distro có sẵn hoặc tạo mới
- **7.2 Tạo Custom Board Configuration:**
  - Tùy chỉnh kernel config, U-Boot
  - Tạo machine file mới
  - Upstream patches qua `meta-freescale@yoctoproject.org`
- **7.3 Giám sát CVE:**
  - Cách 1: Vigiles (Timesys) - auto CVE mỗi build
  - Cách 2: Yocto BitBake CVE Check (`cve-check`)

**Cấu hình Vigiles:**
```bash
# bblayers.conf
BBLAYERS += "${BSPDIR}/sources/meta-timesys"
# local.conf
INHERIT += "vigiles"
```

---

## 8. FAQ & Quick Start

**File:** [`i.MX_6UL_FAQ.md`](i.MX_6UL_FAQ.md)

**Nội dung chính:**
- **8.1 Quick Start:** Toàn bộ quy trình cho 6UL
- **8.2 Tối ưu hóa Build:** Chia sẻ cache qua `DL_DIR` và `SSTATE_DIR`
- **8.3 Recipes:** Cấu trúc recipe, dùng bbappend
- **8.4 Quản lý Packages:** Thêm package, preferred version/provider, SoC family
- **8.5 Đọc BitBake Logs:** Bảng log files khi lỗi
- **8.6 CVE Monitoring:** Cài meta-timesys, cấu hình Vigiles

**Xử lý lỗi fetch:**
```bash
touch <package_name>.done
bitbake <component>
```

---

## 🔍 Mẹo tra cứu nhanh

### Tôi cần...

**Xem machine names nào hỗ trợ 6UL** → Đọc [i.MX_6UL_Features.md](i.MX_6UL_Features.md) phần **Overview** hoặc [i.MX_6UL_Image_Build.md](i.MX_6UL_Image_Build.md) bảng Machine

**Biết image nào dùng được cho 6UL** → Đọc [i.MX_6UL_Image_Build.md](i.MX_6UL_Image_Build.md) bảng **5.2 Chọn Image**

**Build với Frame Buffer** → Đọc [i.MX_6UL_Image_Build.md](i.MX_6UL_Image_Build.md) phần **5.1** và **5.6**

**Flash SD card** → Đọc [i.MX_6UL_Image_Deployment.md](i.MX_6UL_Image_Deployment.md)

**Tạo custom board** → Đọc [i.MX_6UL_Customization.md](i.MX_6UL_Customization.md) phần **7.2**

**Giám sát CVE** → Đọc [i.MX_6UL_Customization.md](i.MX_6UL_Customization.md) phần **7.3**

**Xem BitBake log khi lỗi** → Đọc [i.MX_6UL_FAQ.md](i.MX_6UL_FAQ.md) bảng **8.5**

**Tối ưu build time/dung lượng** → Đọc [i.MX_6UL_FAQ.md](i.MX_6UL_FAQ.md) phần **8.2**

---

## 📂 Vị trí các file

Thư mục hiện tại: `DOC_IMX6UL/IMX6UL/i.MX_Yocto_Project_User's_Guide/`

```bash
i.MX_Yocto_Project_User's_Guide/
├── index.md                    (file này)
├── i.MX_6UL.md                 (Chapter 1: Overview)
├── i.MX_6UL_Features.md        (Chapter 2: Features)
├── i.MX_6UL_Host_Setup.md      (Chapter 3: Host Setup)
├── i.MX_6UL_Yocto_Project_Setup.md  (Chapter 4: Yocto Project Setup)
├── i.MX_6UL_Image_Build.md     (Chapter 5: Image Build)
├── i.MX_6UL_Image_Deployment.md    (Chapter 6: Image Deployment)
├── i.MX_6UL_Customization.md  (Chapter 7: Customization)
└── i.MX_6UL_FAQ.md             (Chapter 8: FAQ & Quick Start)
```

---

## 📌 Lưu ý quan trọng

- **BSP Version:** LF6.18.2_1.0.0
- **Yocto Project:** 5.3 (Whinlatter)
- **Ubuntu:** Tối thiểu 22.04
- **EULA:** Cần đồng ý NXP EULA để fetch packages từ i.MX mirror
- **GPU:** i.MX 6UL **không có GPU Vivante** → không dùng được `imx-image-full`
- **Machine Learning:** Không hỗ trợ trên 6UL (chỉ i.MX 8/9)

---

*Index này được tạo dựa trên việc đọc và phân tích toàn bộ i.MX Yocto Project User's Guide cho i.MX 6UL. Mỗi chương đã được tóm tắt với các điểm chính để tra cứu nhanh.*
