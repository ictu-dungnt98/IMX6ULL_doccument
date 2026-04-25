# i.MX 6UL – Chapter 8: FAQ & Hướng dẫn nhanh

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## 8.1 Quick Start – Toàn bộ quy trình cho i.MX 6UL

### Bước 1: Cài Repo tool (chỉ cần làm 1 lần)

```bash
mkdir ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
PATH=${PATH}:~/bin
```

### Bước 2: Tải BSP (1 lần cho mỗi release)

```bash
mkdir imx-yocto-bsp
cd imx-yocto-bsp
repo init -u https://github.com/nxp-imx/imx-manifest \
    -b imx-linux-whinlatter \
    -m imx-6.18.2-1.0.0.xml
repo sync
```

### Bước 3: Setup backend cho i.MX 6UL

> Frame Buffer **chỉ hỗ trợ i.MX 6 và i.MX 7** – đây là lợi thế của 6UL so với i.MX 8/9.

```bash
# Frame Buffer (phổ biến nhất cho 6UL)
DISTRO=fsl-imx-fb MACHINE=imx6ulevk source imx-setup-release.sh -b build-fb

# Wayland
DISTRO=fsl-imx-wayland MACHINE=imx6ulevk source imx-setup-release.sh -b build-wayland

# XWayland
DISTRO=fsl-imx-xwayland MACHINE=imx6ulevk source imx-setup-release.sh -b build-xwayland
```

### Bước 4: Build image

```bash
# Build không có Qt (phù hợp với 6UL)
bitbake imx-image-multimedia

# KHÔNG dùng cho 6UL (yêu cầu GPU)
# bitbake imx-image-full
```

---

## 8.2 Tối ưu hóa Build (Local Config Tuning)

Chia sẻ cache giữa nhiều build directory để tiết kiệm thời gian và dung lượng. Thêm vào `conf/local.conf`:

```bash
DL_DIR="/opt/imx/yocto/imx/download"
SSTATE_DIR="/opt/imx/yocto/imx/sstate-cache"
```

> Các thư mục này phải tồn tại sẵn và có quyền phù hợp trước khi build.

**Xử lý lỗi fetch package:**

Nếu mạng bị lỗi khi fetch, copy package backup vào `DL_DIR` rồi tạo file `.done`:

```bash
touch <package_name>.done
bitbake <component>
```

---

## 8.3 Recipes

- Mỗi component được build bằng một recipe chỉ định `SRC_URI` và các patch.
- Dùng **bbappend** để thêm patch vào recipe có sẵn mà không sửa recipe gốc:

```bash
# Trong file .bbappend
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://<patch name>.patch"
```

> Nếu bbappend không được nhận, kiểm tra `log.do_fetch` trong thư mục work để xem patch có được include không.

---

## 8.4 Quản lý Packages

### Thêm package vào image

```bash
# Thêm vào conf/local.conf
CORE_IMAGE_EXTRA_INSTALL:append = " <package_name1> <package_name2>"
```

### Chỉ định phiên bản ưu tiên (Preferred Version)

```bash
# Trong local.conf
PREFERRED_VERSION_<component>:<soc_family> = "<version>"
```

### Chỉ định provider ưu tiên (Preferred Provider)

Ví dụ, dùng U-Boot của i.MX thay vì community:

```bash
# Trong local.conf
PREFERRED_PROVIDER_u-boot_mx6 = "u-boot-imx"
```

### SoC Family cho i.MX 6UL

SoC family dùng để áp dụng thay đổi cho một nhóm chip cụ thể. Ví dụ:

```bash
# Chỉ áp dụng cho i.MX 6DL
KERNEL_DEVICETREE:mx6dl = "imx6dl-sabresd.dts"
```

---

## 8.5 Đọc BitBake Logs khi gặp lỗi

| Lỗi | File log cần xem |
|-----|-----------------|
| Fetch thất bại | `tmp/work/<arch>/<component>/temp/log.do_fetch` |
| Compile thất bại | `tmp/work/<arch>/<component>/temp/log.do_compile` |
| Deploy không như mong đợi | Kiểm tra `package/`, `packages-split/`, `sysroot*/` trong `tmp/work/<arch>/<component>/` |

---

## 8.6 CVE Monitoring – Vigiles

### Cài meta-timesys

```bash
cd imx-yocto-bsp/sources
git clone https://github.com/TimesysGit/meta-timesys.git -b master
```

### Cấu hình

```bash
# conf/bblayers.conf
BBLAYERS += "${BSPDIR}/sources/meta-timesys"

# conf/local.conf
INHERIT += "vigiles"
```

### Lấy báo cáo đầy đủ

1. Đăng ký tài khoản: https://www.timesys.com/register-nxp-vigiles/
2. Vào **Preferences** → tạo **New Key** → download file key
3. Khai báo key trong `conf/local.conf`:

```bash
VIGILES_KEY_FILE = "/tools/timesys/linuxlink_key"
```

> Không có key, Vigiles chạy ở **Demo Mode** – chỉ xuất summary report.

Xem thêm cách dùng Vigiles tại **Section 7.3**.