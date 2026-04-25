# i.MX 6UL – Chapter 7: Customization

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## 3 hướng tùy chỉnh chính

1. **Build và validate** trên i.MX reference board – theo hướng dẫn trong tài liệu này.
2. **Tùy chỉnh kernel + custom board + device tree** – xem mục *"How to build U-Boot and Kernel in standalone environment"* trong *i.MX Linux User's Guide (UG10163)*.
3. **Tùy chỉnh distro** – thêm/bớt package bằng cách tạo custom Yocto Project layer.

---

## 7.1 Tạo Custom Distro

Các distro mẫu có sẵn: `fsl-imx-wayland`, `fsl-imx-xwayland`, `fsl-imx-fb`.

**Khuyến nghị:** Mỗi khách hàng nên tạo distro riêng để quản lý providers, versions, và cấu hình build.

Cách tạo:
- Copy một distro file có sẵn (ví dụ `fsl-imx-fb.conf` cho i.MX 6UL)
- Hoặc include `poky.conf` rồi thêm các thay đổi cần thiết
- Hoặc include một trong các i.MX distro làm điểm xuất phát

---

## 7.2 Tạo Custom Board Configuration

Dành cho vendor phát triển board mới dựa trên i.MX 6UL.

### Điều kiện tiên quyết
- Linux kernel và bootloader (U-Boot) phải hoạt động và được test ổn định trên board mới.
- Phải có maintainer chịu trách nhiệm cập nhật kernel, bootloader, và user-space packages.

### Các bước thực hiện

**1. Tùy chỉnh kernel config**

File cấu hình kernel nằm tại `arch/arm/configs`. Vendor kernel recipe nên load version tùy chỉnh qua kernel recipe.

**2. Tùy chỉnh U-Boot**

Xem *i.MX Porting Guide (UG10165)* để biết chi tiết.

**3. Setup Yocto Project community build**

```bash
# Cài host packages theo Yocto Project Quick Start

# Tải Repo tool
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo

# Tạo thư mục project
mkdir imx-community-bsp
cd imx-community-bsp

# Init repo với master branch
repo init -u https://github.com/Freescale/fsl-community-bsp-platform -b master

# Sync recipes
repo sync

# Setup môi trường
source setup-environment build
```

**4. Tạo machine file mới**

- Copy machine file tương tự từ `fsl-community-bsp/sources/meta-freescale-3rdparty/conf/machine/`
- Đặt tên phù hợp với board
- Chỉnh sửa: tên, mô tả, `MACHINE_FEATURE`

**5. Test**

```bash
bitbake core-image-minimal
```

**6. Upstream**

- Chuẩn bị patch theo *Recipe Style Guide* và hướng dẫn Contributing tại `github.com/Freescale/meta-freescale`
- Gửi patch tới: `meta-freescale@yoctoproject.org` để upstream vào `meta-freescale-3rdparty`

---

## 7.3 Giám sát CVE (Bảo mật BSP)

### Cách 1: Vigiles (NXP + Timesys)

Vigiles phân tích CVE tự động mỗi lần build, so sánh metadata với database từ NIST, Ubuntu,...

**Đăng ký tài khoản:** https://www.timesys.com/register-nxp-vigiles/

**Cấu hình:**

```bash
# Thêm vào conf/bblayers.conf
BBLAYERS += "${BSPDIR}/sources/meta-timesys"

# Thêm vào conf/local.conf
INHERIT += "vigiles"
```

**Kết quả:** Sau mỗi build, báo cáo lưu tại `imx-yocto-bsp/<build dir>/vigiles/`. Mở file `<image name>-report.txt` để xem link báo cáo chi tiết online.

---

### Cách 2: Yocto BitBake CVE Check

**Cấu hình:**

```bash
# Thêm vào conf/local.conf
INHERIT += "cve-check"
```

**Chạy kiểm tra:**

```bash
# Kiểm tra một package
bitbake -c cve_check <package>

# Kiểm tra toàn bộ image
bitbake --runall=cve_check <image>
```

**Kết quả:** `<build-dir>/tmp/log/cve/cve-summary.json`

> Tham khảo thêm: *Section 5 "Classes"* trong *Yocto Project Reference Manual*.