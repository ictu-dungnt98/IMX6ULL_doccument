# i.MX 6UL – Chapter 5: Image Build

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## 5.1 Build Configurations

Script `imx-setup-release.sh` dùng để setup môi trường build cho từng machine và graphical backend.

### Machine configurations cho i.MX 6UL

| Machine name | Board |
|---|---|
| `imx6ulevk` | i.MX 6UltraLite EVK |
| `imx6ulz-14x14-evk` | i.MX 6ULZ 14x14 EVK |
| `imx6ull14x14evk` | i.MX 6ULL 14x14 EVK |
| `imx6ull9x9evk` | i.MX 6ULL 9x9 EVK |

### DISTRO hỗ trợ cho i.MX 6UL

| DISTRO | Mô tả | Hỗ trợ 6UL? |
|--------|--------|-------------|
| `fsl-imx-wayland` | Pure Wayland graphics | ✅ |
| `fsl-imx-xwayland` | Wayland + X11 | ✅ |
| `fsl-imx-fb` | Frame Buffer – không có X11/Wayland | ✅ (chỉ i.MX 6 và 7) |

> **Lưu ý:** Nếu không chỉ định DISTRO, mặc định là `fsl-imx-xwayland`.

### Cú pháp chạy script setup

```bash
DISTRO=<distro name> MACHINE=<machine name> source imx-setup-release.sh -b <build dir>
```

**Ví dụ cho i.MX 6UL EVK với Frame Buffer:**

```bash
DISTRO=fsl-imx-fb MACHINE=imx6ulevk source imx-setup-release.sh -b build-fb
```

### File cấu hình sau khi setup

`<build dir>/conf/local.conf` chứa:

```
MACHINE ??= 'imx6ulevk'
DISTRO ?= 'fsl-imx-fb'
ACCEPT_FSL_EULA = "1"
```

---

## 5.2 Chọn Image

| Image | Mô tả | Hỗ trợ i.MX 6UL? |
|-------|--------|------------------|
| `core-image-minimal` | Image nhỏ nhất, chỉ boot được | ✅ |
| `core-image-base` | Console-only, hỗ trợ đầy đủ phần cứng | ✅ |
| `fsl-image-machinetest` | Console, không có GUI | ✅ |
| `imx-image-core` | i.MX test apps, dùng cho Wayland backend | ✅ |
| `imx-image-multimedia` | GUI không có Qt | ✅ |
| `imx-image-full` | Qt 6 + Machine Learning | ❌ **Không hỗ trợ i.MX 6UltraLite** |

> **Quan trọng:** `imx-image-full` **không được hỗ trợ** trên i.MX 6UltraLite, 6UltraLiteLite, 6SLL, 7Dual, 8MNanoLite, và 8DXL.

---

## 5.3 Build Image

```bash
bitbake imx-image-multimedia
```

---

## 5.4 BitBake Options

| Tham số | Mô tả |
|---------|--------|
| `-c fetch` | Fetch source nếu chưa done |
| `-c cleanall` | Xóa toàn bộ build dir của component |
| `-c deploy` | Deploy image/component vào rootfs |
| `-k` | Tiếp tục build dù có lỗi |
| `-c compile -f` | Bắt buộc recompile sau khi deploy |
| `-g` | Hiển thị dependency tree |
| `-DDD` | Bật debug 3 cấp độ |
| `-s` | Hiện version hiện tại và preferred của tất cả recipe |

---

## 5.5 U-Boot Configuration cho i.MX 6UL

i.MX 6 hỗ trợ SD boot có và không có OP-TEE.

| Board | U-Boot config |
|-------|--------------|
| `imx6ulevk` | `sd emmc qspi1 sd-optee` |
| `imx6ul9x9evk` | `sd qspi1 sd-optee` |
| `imx6ull14x14evk` | `sd emmc qspi1 nand sd-optee` |
| `imx6ull9x9evk` | `sd qspi1 sd-optee` |
| `imx6ulz14x14evk` | `sd emmc qspi1 nand sd-optee` |

**Build với một U-Boot config:**

```bash
echo "UBOOT_CONFIG = \"sd\"" >> conf/local.conf
MACHINE=imx6ulevk bitbake -c deploy u-boot-imx
```

**Build với nhiều U-Boot config:**

```bash
echo "UBOOT_CONFIG = \"sd emmc qspi1\"" >> conf/local.conf
MACHINE=imx6ulevk bitbake -c deploy u-boot-imx
```

---

## 5.6 Build Scenarios

### Setup BSP (chung cho mọi board)

```bash
mkdir imx-yocto-bsp
cd imx-yocto-bsp
repo init -u https://github.com/nxp-imx/imx-manifest \
    -b imx-linux-whinlatter \
    -m imx-6.18.2-1.0.0.xml
repo sync
```

### i.MX 6UL EVK – Frame Buffer backend

```bash
DISTRO=fsl-imx-fb MACHINE=imx6ulevk source imx-setup-release.sh -b build-fb
bitbake imx-image-multimedia
```

### i.MX 6ULL 14x14 EVK – XWayland backend

```bash
DISTRO=fsl-imx-xwayland MACHINE=imx6ull14x14evk source imx-setup-release.sh -b build-xwayland
bitbake imx-image-multimedia
```

### Khởi động lại môi trường build (sau khi reboot hoặc mở terminal mới)

```bash
source setup-environment <build-dir>
```

---

## 5.7 Tính năng bổ sung – Áp dụng được cho i.MX 6UL

### OP-TEE
- OP-TEE được **bật mặc định** trong release này.
- i.MX 6UL hỗ trợ U-Boot config `sd-optee`.
- Để tắt OP-TEE: vào `meta-imx/meta-imx-bsp/conf/layer.conf` và comment dòng `DISTRO_FEATURES_append` cho OP-TEE.

### Systemd
- Systemd được bật mặc định làm init manager.
- Để tắt: vào `fsl-imx-base.inc` và comment phần systemd.

---

## Không áp dụng cho i.MX 6UL

| Tính năng | Lý do |
|-----------|-------|
| `imx-image-full` (Qt 6 + ML) | Yêu cầu GPU hardware |
| Chromium Browser | Deprecated trên i.MX 6/7 trong release này |
| QtWebEngine | Yêu cầu GPU hardware |
| NXP eIQ Machine Learning | Chỉ hỗ trợ i.MX 8/9 |
| Jailhouse Hypervisor | Chỉ hỗ trợ i.MX 8M Plus, 8M Nano, 8M Quad, 93, 95, 943 |